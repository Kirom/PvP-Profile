# Contributing to PvP Profile

Thank you for your interest in contributing to PvP Profile! This document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to a code of conduct that I expect all contributors to follow:

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment for all contributors
- Be patient with new contributors

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, please include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **WoW version and addon version**
- **Screenshots** if applicable
- **Error messages** from the game or Lua errors

### Suggesting Features

Feature requests are welcome! Please:

- Check existing issues for similar requests
- Clearly describe the feature and its benefits
- Explain how it fits with the addon's purpose
- Consider implementation complexity

### Code Contributions

#### Development Setup

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/PvP-Profile.git
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Coding Standards

- **Lua Style**: Follow standard Lua conventions
- **Indentation**: Use 4 spaces (no tabs)
- **Naming**: Use camelCase for functions, UPPER_CASE for constants
- **Comments**: Document complex logic and public APIs
- **Error Handling**: Always include proper error handling

#### Code Structure

```lua
-- File header with description
local addonName, ns = ...

-- Constants at the top
local CONSTANT_VALUE = "value"

-- Local functions before global ones
local function LocalFunction()
    -- Implementation
end

-- Public API functions
function ns.PublicFunction()
    -- Implementation
end
```

#### Testing

- **Manual Testing**: Test your changes in-game
- **Cross-realm Testing**: Test with players from different realms
- **Menu Testing**: Verify all context menus work correctly
- **Region Testing**: Test region detection if applicable

#### Commit Guidelines

- Use clear, descriptive commit messages
- Start with a verb (Add, Fix, Update, Remove)
- Keep the first line under 50 characters
- Add detailed description if needed

Examples:
```
Add support for enemy player context menus

Fix realm translation for hyphenated realm names

Update region detection to handle edge cases
```

#### Pull Request Process

1. **Update documentation** if needed
2. **Test thoroughly** in different scenarios
3. **Update CHANGELOG.md** with your changes
4. **Create the pull request** with:
   - Clear title and description
   - Reference any related issues
   - Screenshots/videos if UI changes
   - Testing details

### Releasing (Maintainers)

Releases are automated by `scripts/release.sh`. The script syncs all version
metadata, scaffolds release notes, and creates/pushes the tag that triggers the
GitHub Actions release pipeline (GitHub release, CurseForge, Wago, WowUp).

> **Note:** The release workflow copies `ReleaseNotes/v<version>.md` to
> `CHANGELOG.md`, so that file **must** exist for the release to succeed. The
> script scaffolds it for you if it's missing.

#### Usage

```bash
scripts/release.sh [VERSION] [options]
```

| Option | Description |
| --- | --- |
| `--retail <interface>` | New Retail interface number (e.g. `120005`), updates `PvPProfile.toc` |
| `--classic <interface>` | New Classic interface number (e.g. `50504`), updates `PvPProfile_Classic.toc` |
| `--notes <text>` | One-line summary used in the release notes and commit message |
| `--type <type>` | Release type label (default: `Patch Release`) |
| `-y`, `--yes` | Skip confirmation prompts (non-interactive) |
| `--dry-run` | Make file changes but do **not** commit/tag/push |
| `-h`, `--help` | Show usage |

The TOC files are the source of truth for interface versions; the script derives
`package.json` (`version`, `wow.interface`, `distribution.curseforge.gameVersions`)
and the README badge from them.

#### What it does

1. Bumps interface versions in both TOC files (if `--retail`/`--classic` given)
2. Syncs `package.json` and the README Game Version badge
3. Bumps the `package.json` version
4. Scaffolds `ReleaseNotes/v<version>.md` (skipped if it already exists, so you
   can pre-write detailed notes)
5. Commits, tags `v<version>`, and pushes — triggering the release pipeline

#### Examples

```bash
# Compatibility bump for MoP Classic, non-interactive
scripts/release.sh 1.0.13 --classic 50504 --notes "MoP Classic 5.5.4 compat" -y

# Minor release with a new Retail interface; review changes before pushing
scripts/release.sh 1.1.0 --retail 120100 --type "Minor Release" --dry-run
```

For detailed/hand-written release notes, create `ReleaseNotes/v<version>.md`
before running (the script won't overwrite it), or use `--dry-run` to generate
the scaffold, edit it, then re-run without `--dry-run`.

### Documentation

Help improve documentation by:

- Fixing typos or unclear instructions
- Adding examples or use cases
- Updating outdated information
- Translating to other languages

## Development Guidelines

### Addon Architecture

- **core.lua**: Main addon logic and menu integration
- **db_realms.lua**: Realm name translation database
- **PvPProfile.toc**: Addon metadata and dependencies

### Key Principles

1. **Compatibility**: Maintain compatibility with current WoW version
2. **Performance**: Keep the addon lightweight and efficient
3. **User Experience**: Prioritize ease of use and intuitive design
4. **Reliability**: Handle edge cases and errors gracefully

### Adding New Features

When adding features:

1. **Consider the scope**: Does it fit the addon's purpose?
2. **Check performance impact**: Avoid heavy operations
3. **Test edge cases**: Cross-realm, different regions, etc.
4. **Document the feature**: Update README and help text

### Debugging

Enable debug mode in-game:
```
/pvpprofile debug
```

This provides detailed console output for:
- Region detection
- Realm translation
- Menu context data
- URL generation

## Community

- **Issues**: Use GitHub Issues for bugs and features
- **Discussions**: Use GitHub Discussions for questions
- **Discord**: Join our Discord server (link in README)

## Recognition

Contributors will be recognized in:
- The project's contributors list
- Release notes for significant contributions
- Special thanks in the README

## Questions?

If you have questions about contributing:

1. Check existing issues and discussions
2. Create a new discussion on GitHub
3. Join our Discord server
4. Contact the maintainers

Thank you for helping make PvP Profile better!💝💝💝