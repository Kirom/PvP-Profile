# PvP Profile

A modular World of Warcraft addon that provides convenient access to multiple PvP websites through right-click context menus. PvP Profile supports multiple providers and allows users to choose which websites they want to use. Supports LFG search results and applicants and generates full URLs for the player that is selected by default and can be copied to the clipboard immediately with Ctrl+C.

## 🎯 Key Features

* **Multi-Website Support**: Currently supports Check-PvP.fr, Drustvar.com, and Seramate.com with easy expansion for additional sites
* **Configurable Providers**: Enable or disable individual websites through the options panel
* **Direct Menu Integration**: Individual buttons for each enabled website directly in context menus
* **Right-click Integration**: Works on LFG entries, party members, guild members, friends, targets, and more
* **Dual Copy Modes**: Choose between name-realm format or full URLs
* **Cross-realm Support**: Properly handles players from different realms
* **Region Detection**: Automatically detects your region (US, EU, KR, TW, CN)
* **Persistent Settings**: All preferences saved between sessions
* **Comprehensive Coverage**: Works in all major player contexts

## 🔗 Supported Websites

- **[Check-PvP.fr](https://check-pvp.fr/)** - Retail and [classic](https://check-pvp-classic.fr/) support
- **[Drustvar.com](https://drustvar.com/)** - Retail only
- **[Seramate.com](https://seramate.com/)** - Retail only

### Classic WoW Support
- **Check-PvP**: Full support with [check-pvp-classic.fr](https://check-pvp-classic.fr/)
- **Drustvar & Seramate**: Retail versions only (no classic equivalents)

## 📖 Usage

### Basic Usage

1. **Right-click on any player** (target, party member, guild member, friend, LFG entry, etc.)
2. Look for individual website buttons in the context menu (e.g., "Check-PvP", "Drustvar", "Seramate")
3. **Click the desired option** to open a dialog with the profile link or name-realm
4. **Press Ctrl+C** to copy to your clipboard
5. **Use the copied content** in your browser or for searching

### Configuration Options

Access the options panel through:
- Interface Options → AddOns → PvP Profile
- Slash command: `/pvpprofile options` or `/pvp options`

**Available Settings:**
- **Copy Mode**: Choose between "Name-Realm" (for manual searching) or "Full URL" (direct links)
- **Auto-close Dialog**: Automatically close the copy dialog after Ctrl+C
- **Website Selection**: Enable/disable individual website providers

### Slash Commands

- `/pvpprofile` or `/pvp` - Show help
- `/pvpprofile usename` - Switch to name-realm copy mode
- `/pvpprofile useurl` - Switch to URL copy mode
- `/pvpprofile mode` - Show current copy mode
- `/pvpprofile autoclose` - Toggle auto-close dialog
- `/pvpprofile debug` - Toggle debug output
- `/pvpprofile options` - Open options panel
- `/pvpprofile providers` - List available providers
- `/pvpprofile enable <provider>` - Enable a specific provider
- `/pvpprofile disable <provider>` - Disable a specific provider

## 🐛 Troubleshooting

**Common Issues:**

- **No menu options appear**: Check that at least one provider is enabled in options

## 🙏 Acknowledgments

### **Website Creators & Providers**
- **[Check-PvP.fr](https://check-pvp.fr/)** - Retail and [classic support](https://check-pvp-classic.fr/)
- **[Drustvar.com](https://drustvar.com/)** - Retail only
- **[Seramate.com](https://seramate.com/)** - Retail only

### **Special Thanks**
- The creators and maintainers of Check-PvP.fr, Drustvar.com, and Seramate.com for providing excellent PvP tracking services
- BigWigs team for their excellent addon packaging and distribution tools

---

**Happy PvP hunting! 🗡️⚔️** 