#!/bin/bash

# Release helper script for PvP Profile
#
# Automates the full release flow:
#   1. (optional) Bump Retail/Classic interface versions in both TOC files
#   2. Sync package.json (version, wow.interface, curseforge gameVersions)
#   3. Update the Game Version badge in README.md
#   4. Scaffold ReleaseNotes/vX.Y.Z.md from a template (REQUIRED: the release
#      workflow copies this file to CHANGELOG.md, so a release without it fails)
#   5. Commit, tag and push -> triggers the GitHub Actions release pipeline
#
# Usage:
#   scripts/release.sh [VERSION] [options]
#
# Options:
#   --retail   <interface>   New Retail interface number   (e.g. 120005)
#   --classic  <interface>   New Classic interface number  (e.g. 50504)
#   --notes    <text>        One-line summary for the release notes / commit
#   --type     <type>        Release type label (default: "Patch Release")
#   -y, --yes                Skip confirmation prompts (non-interactive)
#   --dry-run                Make file changes but do NOT commit/tag/push
#   -h, --help               Show this help
#
# Examples:
#   scripts/release.sh 1.0.13 --classic 50504 --notes "MoP Classic 5.5.4 compat"
#   scripts/release.sh 1.1.0 --retail 120100 --type "Minor Release" -y

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Portable in-place sed (BSD/macOS sed requires -i '', GNU sed requires -i)
sed_i() {
    local expr=$1 file=$2
    if sed --version >/dev/null 2>&1; then
        sed -i "$expr" "$file"
    else
        sed -i '' "$expr" "$file"
    fi
}

RETAIL_TOC="PvPProfile.toc"
CLASSIC_TOC="PvPProfile_Classic.toc"
REPO_URL="https://github.com/Kirom/PvP-Profile"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
NEW_VERSION=""
NEW_RETAIL_INTERFACE=""
NEW_CLASSIC_INTERFACE=""
NOTES=""
RELEASE_TYPE="Patch Release"
ASSUME_YES=false
DRY_RUN=false

print_help() {
    sed -n '3,30p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --retail)   NEW_RETAIL_INTERFACE="$2"; shift 2 ;;
        --classic)  NEW_CLASSIC_INTERFACE="$2"; shift 2 ;;
        --notes)    NOTES="$2"; shift 2 ;;
        --type)     RELEASE_TYPE="$2"; shift 2 ;;
        -y|--yes)   ASSUME_YES=true; shift ;;
        --dry-run)  DRY_RUN=true; shift ;;
        -h|--help)  print_help ;;
        -*)         echo -e "${RED}❌ Unknown option: $1${NC}"; exit 1 ;;
        *)
            if [ -z "$NEW_VERSION" ]; then NEW_VERSION="$1"; shift
            else echo -e "${RED}❌ Unexpected argument: $1${NC}"; exit 1; fi
            ;;
    esac
done

echo -e "${BLUE}🚀 PvP Profile Release Helper${NC}"
echo "======================================="

confirm() {
    # confirm "message" -> returns 0 on yes
    if [ "$ASSUME_YES" = true ]; then return 0; fi
    read -p "$1 (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid version format. Use semantic versioning (e.g., 1.0.1)${NC}"
        exit 1
    fi
}

validate_interface() {
    # 5 or 6 digit interface number
    if [[ ! $1 =~ ^[0-9]{5,6}$ ]]; then
        echo -e "${RED}❌ Invalid interface number '$1' (expected 5-6 digits, e.g. 120005)${NC}"
        exit 1
    fi
}

# Convert interface number to version string: 120005 -> 12.0.5, 50504 -> 5.5.4
convert_interface_to_version() {
    local interface_num=$1
    if [[ ${#interface_num} -eq 6 ]]; then
        echo "$((10#${interface_num:0:2})).$((10#${interface_num:2:2})).$((10#${interface_num:4:2}))"
    elif [[ ${#interface_num} -eq 5 ]]; then
        echo "$((10#${interface_num:0:1})).$((10#${interface_num:1:2})).$((10#${interface_num:3:2}))"
    else
        echo "unknown"
    fi
}

extract_interface_version() {
    local toc_file=$1
    if [ -f "$toc_file" ]; then
        local interface_line
        interface_line=$(grep "^## Interface:" "$toc_file" | head -1)
        if [[ $interface_line =~ Interface:[[:space:]]*([0-9]+) ]]; then
            echo "${BASH_REMATCH[1]}"
        fi
    fi
}

set_toc_interface() {
    local toc_file=$1 new_interface=$2
    if [ ! -f "$toc_file" ]; then
        echo -e "${RED}❌ $toc_file not found!${NC}"; exit 1
    fi
    sed_i "s/^## Interface:.*/## Interface: ${new_interface}/" "$toc_file"
    echo -e "${GREEN}✅ ${toc_file}: Interface -> ${new_interface}${NC}"
}

update_interface_versions_in_readme() {
    local retail_version=$1 classic_version=$2 readme_file="README.md"
    [ -f "$readme_file" ] || { echo -e "${RED}❌ README.md not found!${NC}"; return 1; }
    local new_badge="[![Interface Version](https://img.shields.io/badge/Game%20Version-${retail_version}%20|%20${classic_version}-brightgreen)](${REPO_URL})"
    awk -v new_badge="$new_badge" '
        /\[!\[Interface Version\]/ { print new_badge; next }
        { print }
    ' "$readme_file" > "${readme_file}.tmp" && mv "${readme_file}.tmp" "$readme_file"
    echo -e "${GREEN}✅ README.md badge -> ${retail_version} | ${classic_version}${NC}"
}

# Update a top-level "key": "value" string in package.json (simple, dependency-free)
set_json_string() {
    local key=$1 value=$2 file="package.json"
    sed_i "s/\"${key}\": \"[^\"]*\"/\"${key}\": \"${value}\"/" "$file"
}

create_release_notes() {
    local version=$1 retail_version=$2 classic_version=$3 notes=$4 release_type=$5
    local notes_file="ReleaseNotes/v${version}.md"
    local date_str
    date_str=$(date "+%B %-d, %Y" 2>/dev/null || date "+%B %d, %Y")

    if [ -f "$notes_file" ]; then
        echo -e "${GREEN}✅ Release notes already exist: ${notes_file}${NC}"
        return 0
    fi

    mkdir -p ReleaseNotes
    local overview change_body
    if [ -n "$notes" ]; then
        overview="$notes"
        change_body="- ${notes}"
    else
        overview="TODO: summarize this release."
        change_body="- TODO: describe the changes in this release"
    fi

    cat > "$notes_file" <<EOF
# PvP Profile v${version} Release Notes

**Release Date:** ${date_str}
**Version:** ${version}
**Type:** ${release_type}
**Compatibility:** Retail ${retail_version} / MoP Classic ${classic_version}

## Overview

${overview}

## Changes

${change_body}

## Known Issues

None reported for this version.

## Support

If you encounter any issues with this release, please:
1. Check the [GitHub Issues](${REPO_URL}/issues) page
2. Ensure you're using the correct version for your WoW client (retail vs classic)
3. Try disabling other addons to check for conflicts
4. Check the [Discord](https://discord.gg/5sMTavfNsE)

---

**Thank you for using PvP Profile!**
EOF
    echo -e "${GREEN}✅ Created release notes: ${notes_file}${NC}"
    if [ -z "$notes" ]; then
        echo -e "${YELLOW}⚠️  No --notes provided; please review/edit ${notes_file} before continuing.${NC}"
    fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
[ -f "package.json" ] || { echo -e "${RED}❌ package.json not found! Run from repo root.${NC}"; exit 1; }

# Apply interface bumps (if requested) BEFORE reading current values
if [ -n "$NEW_RETAIL_INTERFACE" ]; then
    validate_interface "$NEW_RETAIL_INTERFACE"
    set_toc_interface "$RETAIL_TOC" "$NEW_RETAIL_INTERFACE"
fi
if [ -n "$NEW_CLASSIC_INTERFACE" ]; then
    validate_interface "$NEW_CLASSIC_INTERFACE"
    set_toc_interface "$CLASSIC_TOC" "$NEW_CLASSIC_INTERFACE"
fi

# Read effective interface versions from TOC files (source of truth)
echo -e "${BLUE}🔍 Reading interface versions from TOC files...${NC}"
RETAIL_INTERFACE=$(extract_interface_version "$RETAIL_TOC")
CLASSIC_INTERFACE=$(extract_interface_version "$CLASSIC_TOC")
[ -n "$RETAIL_INTERFACE" ]  || { echo -e "${RED}❌ Could not read interface from $RETAIL_TOC${NC}"; exit 1; }
[ -n "$CLASSIC_INTERFACE" ] || { echo -e "${RED}❌ Could not read interface from $CLASSIC_TOC${NC}"; exit 1; }

RETAIL_VERSION=$(convert_interface_to_version "$RETAIL_INTERFACE")
CLASSIC_VERSION=$(convert_interface_to_version "$CLASSIC_INTERFACE")

echo -e "${BLUE}📋 Interface versions:${NC}"
echo -e "   Retail:  ${GREEN}$RETAIL_VERSION${NC} (Interface: $RETAIL_INTERFACE)"
echo -e "   Classic: ${GREEN}$CLASSIC_VERSION${NC} (Interface: $CLASSIC_INTERFACE)"

# Sync package.json interface fields
set_json_string "interface" "$RETAIL_INTERFACE"
# distribution.curseforge.gameVersions -> [retail, classic]
awk -v retail="$RETAIL_INTERFACE" -v classic="$CLASSIC_INTERFACE" '
    /"gameVersions": \[/ { print; in_gv=1; printed=0; next }
    in_gv && /\]/ {
        if (!printed) { printf "        \"%s\",\n        \"%s\"\n", retail, classic; printed=1 }
        print; in_gv=0; next
    }
    in_gv { next }
    { print }
' package.json > package.json.tmp && mv package.json.tmp package.json
echo -e "${GREEN}✅ package.json: interface + curseforge gameVersions synced${NC}"

# Update README badge
update_interface_versions_in_readme "$RETAIL_VERSION" "$CLASSIC_VERSION"

# Get current version from package.json
CURRENT_VERSION=$(grep '"version":' package.json | head -1 | cut -d'"' -f4)
echo -e "${BLUE}📋 Current version: ${GREEN}$CURRENT_VERSION${NC}"

# Branch check
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}⚠️  On branch '$CURRENT_BRANCH' (not main/master).${NC}"
    confirm "Continue anyway?" || exit 1
fi

# Get new version
if [ -z "$NEW_VERSION" ]; then
    echo -e "${BLUE}🔢 Enter new version (current: $CURRENT_VERSION):${NC}"
    read -r NEW_VERSION
fi
validate_version "$NEW_VERSION"

if git tag -l "v$NEW_VERSION" | grep -q "v$NEW_VERSION"; then
    echo -e "${RED}❌ Tag v$NEW_VERSION already exists!${NC}"; exit 1
fi

# Bump version in package.json
echo -e "${BLUE}📝 Bumping version $CURRENT_VERSION -> $NEW_VERSION...${NC}"
set_json_string "version" "$NEW_VERSION"

# Scaffold release notes (REQUIRED by the release workflow)
create_release_notes "$NEW_VERSION" "$RETAIL_VERSION" "$CLASSIC_VERSION" "$NOTES" "$RELEASE_TYPE"

# Show all staged changes
echo -e "\n${BLUE}📋 Pending changes:${NC}"
git --no-pager diff --stat
git status --porcelain

# Dry run stops here
if [ "$DRY_RUN" = true ]; then
    echo -e "\n${YELLOW}🧪 Dry run: file changes made but nothing committed/tagged/pushed.${NC}"
    echo -e "${BLUE}   Review the changes, then re-run without --dry-run.${NC}"
    exit 0
fi

# Confirm
echo
confirm "🤔 Commit, tag and push release v$NEW_VERSION?" || {
    echo -e "${YELLOW}🔙 Release cancelled. File changes left in working tree for review.${NC}"
    exit 1
}

# Commit everything related to the release
COMMIT_MSG="Release v$NEW_VERSION (interface $RETAIL_VERSION/$CLASSIC_VERSION)"
[ -n "$NOTES" ] && COMMIT_MSG="$COMMIT_MSG: $NOTES"

echo -e "${BLUE}💾 Committing...${NC}"
git add package.json README.md "$RETAIL_TOC" "$CLASSIC_TOC" "ReleaseNotes/v${NEW_VERSION}.md"
git commit -m "$COMMIT_MSG"

echo -e "${BLUE}🏷️  Tagging v$NEW_VERSION...${NC}"
git tag "v$NEW_VERSION" -m "Release version $NEW_VERSION (Interface: $RETAIL_VERSION/$CLASSIC_VERSION)"

echo -e "${BLUE}⬆️  Pushing...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "v$NEW_VERSION"

echo -e "${GREEN}✅ Release v$NEW_VERSION created successfully!${NC}"
echo "======================================="
echo -e "${BLUE}🔗 GitHub Actions will now build & publish (GitHub release, CurseForge, Wago, WowUp).${NC}"
REPO_PATH=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')
echo -e "${BLUE}🌐 Monitor:${NC} https://github.com/${REPO_PATH}/actions"
echo -e "${GREEN}🎉 Release process initiated!${NC}"
