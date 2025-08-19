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