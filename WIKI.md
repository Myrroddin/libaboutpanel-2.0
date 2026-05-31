# LibAboutPanel-2.0 Wiki

## Table of Contents

- [Quick Start](#quick-start)
- [Adding LibAboutPanel-2.0 via .pkgmeta](#adding-libaboutpanel-20-via-pkgmeta)
- [Embedding](#embedding)
- [Ace3 Example Usage](#ace3-example-usage)
- [API Reference](#api-reference)
- [Supported ToC Fields](#supported-toc-fields)
  - [Category vs X-Category](#category-vs-x-category)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Quick Start

See the [README.md](./README.md) for integration steps, dependencies, and a brief overview.

## Embedding

### Ace3 addons

For Ace3 addons, the recommended embedding style is to pass `LibAboutPanel-2.0` to `AceAddon-3.0:NewAddon()`:

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "LibAboutPanel-2.0")
```

This embeds LibAboutPanel-2.0's public API methods into your addon object.

### Non-Ace3 addons

For non-Ace3 addons, embed LibAboutPanel-2.0 directly:

```lua
local MyAddon = {}
LibStub("LibAboutPanel-2.0"):Embed(MyAddon)
```

### Standalone library usage

You may also use the library directly:

```lua
local LAP = LibStub("LibAboutPanel-2.0")
LAP:CreateAboutPanel("MyAddon")
```

## Ace3 Example Usage

Below is a quick example of integrating LibAboutPanel-2.0 with Ace3 in your addon:

```lua
local MyAddOn = LibStub("AceAddon-3.0"):NewAddon("MyAddOn", "LibAboutPanel-2.0")

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
                        self:Enable() -- AceAddon-3.0 function, see Ace3 docs
                    else
                        self:Disable()
                    end
                end
            }
        }
    }
    -- support for LibAboutPanel-2.0
    options.args.aboutTab = self:AboutOptionsTable("MyAddOn")
    options.args.aboutTab.order = -1 -- -1 means "put it last" although you can use any order number you wish

    -- Register your options with AceConfigRegistry
    LibStub("AceConfig-3.0"):RegisterOptionsTable("MyAddOn", options)
end
```

## API Reference

### Create an About Panel

```lua
MyAddon:CreateAboutPanel(addonName, parent)
-- Or, if not embedded:
LibStub("LibAboutPanel-2.0"):CreateAboutPanel(addonName, parent)
```

- `addonName` is your addon's folder name, which should match your `.toc` file.
- Adds an About panel to Blizzard's settings UI.
- Auto-detects and displays metadata from your `.toc` file.
- `parent` is optional; use for nested panels.
- Returns the created or cached About panel frame.

### AceConfig-3.0 Options Table

```lua
MyAddon:AboutOptionsTable(addonName)
-- Or, if not embedded:
LibStub("LibAboutPanel-2.0"):AboutOptionsTable(addonName)
```

- `addonName` is your addon's folder name, which should match your `.toc` file.
- Returns an AceConfig-3.0-compatible options table for About info.
- Does not register the table itself; your addon registers it with AceConfig-3.0 or embeds it in an existing options table.

## Supported ToC Fields

- Author, Title, Notes (all languages)
- Version, X-Date, X-ReleaseDate, X-Project-Revision
- X-Author-Guild, X-Author-Faction, X-Author-Server
- X-Website, X-Email, X-Localizations, X-Credits, Category or X-Category
- X-License, X-Copyright

### `Category` vs `X-Category`

AddOn authors should use `## Category:` based on Blizzard's official
[AddOn Categories](https://warcraft.wiki.gg/wiki/Addon_Categories).

`## X-Category:` and `## X-Category-<locale>` are still supported for
backward compatibility but are considered legacy metadata.

You may specify a single category from the Blizzard list, or multiple
categories separated by commas.

Localized categories must be explicitly declared in the `.toc`
(e.g. `## Category-deDE:`). If no localized field exists,
the base `## Category:` value will be used.

```toc
## Category: Action Bars, Auctions
## Category-deDE: Aktionsleisten, Auktionen
## Category-esES: Barras de acción, Subastas
```

## Features

- Automatic localization for faction, locale, and common strings
- Embedded API for easy integration
- AceConfig-3.0-compatible options table support
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
  Libs/LibAboutPanel-2.0:
    url: https://github.com/Myrroddin/libaboutpanel-2.0/LibAboutPanel-2.0
    curse-slug: libaboutpanel-2-0
```

If your addon uses `:AboutOptionsTable()`, you are responsible for embedding or depending on AceConfig-3.0 in your own addon.

- The `url` points to the GitHub repository for the library.
- The `curse-slug` ensures proper packaging and updates via CurseForge.
