# Changelog

All notable changes to PvP Profile will be documented in this file.

## [1.0.0] - 2025-07-31

### Added
- Initial release of PvP Profile addon
- Multi-website provider system supporting:
  - Check-PvP.fr integration (retail and classic)
  - Drustvar.com integration (retail only)
  - Seramate.com integration (retail only)
- Configurable website enable/disable options
- Direct context menu integration:
  - Individual buttons for each enabled provider
- Comprehensive player context support:
  - LFG search results and applicants
  - Party, raid, and guild members
  - Friends and Battle.net friends
  - Target players and self
- **UI Improvements**: Added "PvP Profile" title to context menus for better organization
- **Enhanced Context Menus**: Individual buttons for each enabled provider always show URLs
- **Optional Name-Realm**: Added configurable "Name-Realm" button for manual searching
- Auto-close dialog functionality
- Extensive slash command interface
- Cross-realm and multi-region support
- Persistent configuration storage
- Debug mode for troubleshooting
- Classic WoW compatibility

### Technical Features
- Modular provider architecture for easy extensibility
- WoW version-aware provider filtering (classic vs retail compatibility)
- Clean separation of concerns across modules
- Comprehensive realm and region detection
- Dynamic options panel generation
- Robust error handling and validation

### Supported Contexts
- All major player interaction contexts in modern WoW
- LFG system integration
- Social features (guild, communities, friends)
- Combat contexts (targets, enemies)

### Website Provider Credits
- **Check-PvP.fr** - retail and classic support
- **Drustvar.com** - retail only
- **Seramate.com** - retail only

---

*This addon was built with extensibility and user choice in mind.*