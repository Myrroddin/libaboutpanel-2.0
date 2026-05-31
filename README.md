# LibAboutPanel-2.0

LibAboutPanel-2.0 is a World of Warcraft Lua library for displaying addon metadata in Blizzard's Settings UI or as an AceConfig-3.0-compatible options table. It works with all valid WoW clients.

## Requirements

- Required: LibStub
- Optional: AceConfig-3.0, if using `:AboutOptionsTable()`

## Quick Usage

For Ace3 addons, embed LibAboutPanel-2.0 when creating your addon object:

```lua
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "LibAboutPanel-2.0")
```

For non-Ace3 addons, embed the library into your addon object:

```lua
LibStub("LibAboutPanel-2.0"):Embed(MyAddon)
```

Or use it directly:

```lua
local LAP = LibStub("LibAboutPanel-2.0")
```

Create a Blizzard Settings About panel:

```lua
MyAddon:CreateAboutPanel("MyAddon")
-- or
LAP:CreateAboutPanel("MyAddon")
```

Create an AceConfig-3.0-compatible About options table:

```lua
options.args.about = MyAddon:AboutOptionsTable("MyAddon")
```

`AboutOptionsTable()` only returns the table. Your addon is responsible for registering it with AceConfig-3.0 or embedding it in an existing options table.

## Documentation

See [WIKI.md](./WIKI.md) for:

- `.pkgmeta` integration
- Ace3 example usage
- API reference
- Supported `.toc` fields
- Category and localization notes
- Troubleshooting

## Contributing

- Help translate or verify localization [at CurseForge](https://legacy.curseforge.com/wow/addons/libaboutpanel-2-0/localization)
- Report bugs or request improvements via the [GitHub issue tracker](https://github.com/Myrroddin/libaboutpanel-2.0/issues)
