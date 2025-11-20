# Table of Contents
- [Quick Start](#quick-start)
- [Adding LibAboutPanel-2.0 via .pkgmeta](#adding-libaboutpanel-20-via-pkgmeta)
- [Ace3 Example Usage](#ace3-example-usage)
- [API Reference](#api-reference)
- [Supported ToC Fields](#supported-toc-fields)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

# LibAboutPanel-2.0 Wiki

## Ace3 Example Usage

Below is a quick example of integrating LibAboutPanel-2.0 with Ace3 in your addon:

```lua
function MyAddOn:OnInitialize()
    local options = {
        name = "MyAddOn",
        type = "group",
        args = {
            enableAddOn = {
                order = 10,
                name = ENABLE, -- use Blizzard's global string
                type = "toggle",
                get = function() return self.db.profile.enableAddOn end,
                set = function(info, value)
                    self.db.profile.enableAddOn = value
                    if value then
                        self:OnEnable()
                    else
                        self:OnDisable()
                    end
                end
            }
        }
    }
    -- support for LibAboutPanel-2.0
    options.args.aboutTab = self:AboutOptionsTable("MyAddOn")
    options.args.aboutTab.order = -1 -- -1 means "put it last"

   -- Register your options with AceConfigRegistry
   LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddOn", options)
end
```

See the [README.md](../README.md) for integration steps, dependencies, and a brief overview.

## API Reference

### Create an About Panel
```lua
MyAddon:CreateAboutPanel(addonName, parent)
-- Or, if not embedded:
LibStub("LibAboutPanel-2.0"):CreateAboutPanel(addonName, parent)
```
- Adds an About panel to Blizzard's settings UI.
- Auto-detects and displays metadata from your `.toc` file.
- `parent` is optional; use for nested panels.

### AceConfig-3.0 Options Table
```lua
MyAddon:AboutOptionsTable(addonName)
-- Or, if not embedded:
LibStub("LibAboutPanel-2.0"):AboutOptionsTable(addonName)
```
- Returns an AceConfig-3.0 options table for About info.
- Integrates with AceConfigDialog for flexible UI placement.

## Supported ToC Fields
- Author, Title, Notes (all languages)
- Version, X-Date, X-ReleaseDate, X-Revision
- X-Author-Guild, X-Author-Faction, X-Author-Server
- X-Website, X-Email, X-Localizations, X-Credits, X-Category
- X-License, X-Copyright

## Features
- Automatic localization for faction, locale, and common strings
- Embedded API for easy integration
- AceConfig-3.0 support for flexible UI placement
- Shared editbox for copying fields (email, website)

## Troubleshooting
- Ensure all dependencies are listed in your `.toc` and loaded before LibAboutPanel-2.0
- For bug reports, provide:
  - Addon name, LAP version, WoW version/build, language
  - Steps to reproduce, error logs (BugSack, Swatter, etc), screenshots

## Contributing
- Help translate or verify localization at CurseForge
- Report bugs or request improvements via the [GitHub issue tracker](https://github.com/Myrroddin/libaboutpanel-2.0/issues)

## Adding LibAboutPanel-2.0 via .pkgmeta

To include LibAboutPanel-2.0 in your addon using CurseForge packaging, add the following to your `.pkgmeta` file:

```yaml
externals:
  Libs/LibStub: https://repos.curseforge.com/wow/libstub/trunk
  Libs/CallbackHandler-1.0: https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0
  Libs/AceConfig-3.0: https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0
  Libs/LibAboutPanel-2.0:
    url: https://github.com/Myrroddin/libaboutpanel-2.0/LibAboutPanel-2.0
    curse-slug: libaboutpanel-2-0
```

- The `url` points to the GitHub repository for the library.
- The `curse-slug` ensures proper packaging and updates via CurseForge.

---
For a quick overview and integration steps, see [README.md](../README.md).
