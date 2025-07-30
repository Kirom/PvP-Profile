#!/bin/bash

# Release helper script for PvP Profile
# This script helps create version tags and trigger GitHub Actions releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 PvP Profile Release Helper${NC}"
echo "======================================="

# Function to validate version format
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid version format. Use semantic versioning (e.g., 1.0.1)${NC}"
        exit 1
    fi
}

# Get current version from package.json
if [ -f "package.json" ]; then
    CURRENT_VERSION=$(grep '"version":' package.json | cut -d'"' -f4)
    echo -e "${BLUE}📋 Current version from package.json: ${GREEN}$CURRENT_VERSION${NC}"
else
    echo -e "${RED}❌ package.json not found!${NC}"
    exit 1
fi

# Check if we have uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes. Please commit them first.${NC}"
    git status --porcelain
    exit 1
fi

# Check if we're on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "${YELLOW}⚠️  You're on branch '$CURRENT_BRANCH'. Consider switching to main/master for releases.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get new version
if [ -z "$1" ]; then
    echo -e "${BLUE}🔢 Enter new version (current: $CURRENT_VERSION):${NC}"
    read -r NEW_VERSION
else
    NEW_VERSION=$1
fi

# Validate version format
validate_version "$NEW_VERSION"

# Check if tag already exists
if git tag -l "v$NEW_VERSION" | grep -q "v$NEW_VERSION"; then
    echo -e "${RED}❌ Tag v$NEW_VERSION already exists!${NC}"
    exit 1
fi

echo -e "${BLUE}📝 Updating version from $CURRENT_VERSION to $NEW_VERSION...${NC}"

# Update package.json only
sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" package.json

# Show changes
echo -e "${BLUE}📋 Changes made:${NC}"
git diff package.json

# Confirm changes
echo -e "\n${YELLOW}🤔 Do you want to commit these changes and create release v$NEW_VERSION?${NC}"
read -p "Continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🔙 Reverting changes...${NC}"
    git checkout -- package.json
    echo -e "${BLUE}✅ Changes reverted. Release cancelled.${NC}"
    exit 1
fi

# Commit version bump
echo -e "${BLUE}💾 Committing version bump...${NC}"
git add package.json
git commit -m "Bump version to $NEW_VERSION"

# Create and push tag
echo -e "${BLUE}🏷️  Creating tag v$NEW_VERSION...${NC}"
git tag "v$NEW_VERSION" -m "Release version $NEW_VERSION"

echo -e "${BLUE}⬆️  Pushing to origin...${NC}"
git push origin "$CURRENT_BRANCH"
git push origin "v$NEW_VERSION"

echo -e "${GREEN}✅ Release v$NEW_VERSION created successfully!${NC}"
echo "======================================="
echo -e "${BLUE}🔗 GitHub Actions will now:${NC}"
echo "   • Create GitHub release"
echo "   • Upload addon package"
echo "   • Publish to CurseForge (if configured)"
echo "   • Publish to Wago (if configured)"
echo "   • Generate WowUp metadata"
echo ""
echo -e "${BLUE}🌐 Monitor progress at:${NC}"
echo "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
echo ""
echo -e "${GREEN}🎉 Release process initiated!${NC}"

# Optional: Open GitHub Actions in browser (uncomment if desired)
# if command -v xdg-open > /dev/null; then
#     xdg-open "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
# elif command -v open > /dev/null; then
#     open "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
# fi 