# Table of Contents
- [Quick Integration](#quick-integration)
- [Adding LibAboutPanel-2.0 via .pkgmeta](#adding-libaboutpanel-20-via-pkgmeta)
- [Ace3 Example Usage](#ace3-example-usage)
- [API Usage](#api-usage)
- [Supported ToC Fields](#supported-toc-fields)
- [Features](#features)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Full Documentation](#full-documentation)

# LibAboutPanel-2.0

LibAboutPanel-2.0 is a World of Warcraft Lua library for displaying addon metadata in the Interface Options panel or AceConfig-3.0 options tables. It works with Classic Era, Classic, and Retail.

## Quick Integration

1. **Dependencies:**
   - Requires: LibStub, CallbackHandler-1.0, AceConfig-3.0
   - Add these to your `.toc` and `.pkgmeta` files.

2. **Embedding:**
   - With Ace3: `local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "LibAboutPanel-2.0")`
   - Without Ace3: `LibStub("LibAboutPanel-2.0"):Embed(MyAddon)`
   - Or use as a standalone library: `local LAP = LibStub("LibAboutPanel-2.0")`

3. **API Usage:**
   - `:CreateAboutPanel(addon, parent)` — Adds an About panel to Blizzard's settings.
   - `:AboutOptionsTable(addon)` — Returns an AceConfig-3.0 options table for About info.
   - Both APIs auto-detect and display metadata from your `.toc` file, including localized fields.

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

See also: [WIKI.md](./WIKI.md) for full documentation and API reference.

For full API details and examples, see the [wiki](https://github.com/Myrroddin/libaboutpanel-2.0/wiki).