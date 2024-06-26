# LibAboutPanel-2.0

An embedded library that scans your AddOn's ToC to display that information either as a seperate __About__ button in the Interface Options panel, or as part of AceConfig-3.0 options table.

## Getting LAP into your own addon

**Step one** is to add LibAboutPanel-2.0 to your addon's .pkgmeta file. Assuming you have a folder named Libs into which you are adding all your libs, the .pkgmeta section would look like one of the following:

### Old method

The old method still works to get the full fat version of LibAboutPanel-2.0, which includes LibStub, CallbackHandler-1.0, and AceConfig-3.0. Use this method if you are not certain what you need for your addon.

```lua
externals:
  Libs/LibAboutPanel-2.0: https://github.com/Myrroddin/libaboutpanel-2.0
```

### New method

If all you need is LibAboutPanel-2.0 because you either do not need AceConfig-3.0 or you have added LibStub, CallbackHandler-1.0, and AceConfig-3.0 as their own folders, use this second method to get the slim version of LibAboutPanel-2.0, which includes the main Lua file and the XML loader, with nothing else.

```lua
externals:
  Libs/LibAboutPanel-2.0:
      url: https://github.com/Myrroddin/libaboutpanel-2.0/LibAboutPanel-2.0
      curse-slug: libaboutpanel-2-0
```

**Step two** is in your ToC file, with either of the above methods, load the .xml file that loads LibAboutPanel-2.0:

`Libs\LibAboutPanel-2.0\lib.xml`

**Step three** is embedding LibAboutPanel-2.0 into your addon to use its APIs. Embedding LAP is optional yet recommended.

```lua
-- using Ace3
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "LibAboutPanel-2.0")

-- not using Ace3
local folderName, MyAddon = ...
LibStub("LibAboutPanel-2.0"):Embed(MyAddon)

-- now you can use the APIs
function MyAddon:DoSomething()
    -- self refers to MyAddon
    self:CreateAboutPanel() -- not strictly accurate, see docs
end

-- not embedding LAP
local folderName, MyAddon = ...
local LAP = LibStub("LibAboutPanel-2.0")

function MyAddon:DoSomething()
    LAP:CreateAboutPanel() -- not strictly accurate, see docs
end
```

Please be aware that capitalization in the .pkgmeta and .toc files matters, and the different slashes ("/" in .pkgmeta and "\\" in .toc files). These conventions are standards set by others. Like any other WoW addon or library, LibAboutPanel-2.0 must follow the standards.

## Retail, Cataclysm, or Classic

LibAboutPanel-2.0 should work in all versions of the game.

## Not a drop-in replacement

LibAboutPanel and LibAboutPanel-2.0 do more or less the same thing, but LAP2 will not replace Ackis' version just because you have it installed. As an author, you can make the choice which you prefer.

## API

You can find the [API and example here](https://github.com/Myrroddin/libaboutpanel-2.0/wiki).

## Features that are new or different than Ackis' LibAboutPanel

* More localization. LAP2 uses global strings to translate factions, locale names, etc. It also has more translatable strings than the original.
* Its API is embedded, so __MyAddOn:API()__ is the norm.
* LAP2 has an API that supports AceConfig-3.0 options tables, thus the About panel can be displayed as a tab, part of a tree, etc.

## List of supported ToC fields

* Author
* Notes in all languages the author has translated
* Title in all languages the author has translated
* Version `@project-version@` is replaced with a translation of `Developer Build`
* X-Date or X-ReleaseDate
* X-Revision including `wowi:revision`
* X-Author-Guild
* X-Author-Faction (Horde or Alliance) translated
* X-Author-Server
* X-Website
* X-Email
* X-Localizations (enUS, deDE, etc) which are translated themselves. Note the z not s
* X-Credits
* X-Category
* X-License `All Rights Reserved` is translated
* X-Copyright `Copyright` and `(c)` are translated

## Localization

There are several phrases and words that [need translating](https://legacy.curseforge.com/wow/addons/libaboutpanel-2-0/localization). Please help and contribute.

## Bugs and suggestions

There is a [ticket tracker](https://github.com/Myrroddin/libaboutpanel-2.0/issues) for suggesting fixes or improvements.