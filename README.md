# LibAboutPanel-2.0

An embedded library that scans your AddOn's ToC to display its fields either as a seperate `About` button in the Interface Options panel, or as part of AceConfig-3.0 options table.

## Getting LAP into your own addon

Follow the steps below.

### Your addon's .pkgmeta file

Assuming you have a folder named Libs into which you are adding all your libs, the .pkgmeta section would look like the following:

```lua
externals:
  Libs/LibAboutPanel-2.0:
    url: https://github.com/Myrroddin/libaboutpanel-2.0/LibAboutPanel-2.0
    curse-slug: libaboutpanel-2-0
```

### Your addon's .toc file

This is quite simple.

`Libs\LibAboutPanel-2.0\lib.xml`

### Using LibAboutPanel-2.0 in your addon

Embedding LibAboutPanel-2.0 is optional yet recommended.

```lua
-- using Ace3, embedded
local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "LibAboutPanel-2.0")

-- not using Ace3, embedded
local folderName, MyAddon = ...
LibStub("LibAboutPanel-2.0"):Embed(MyAddon)

-- now you can use the APIs
function MyAddon:DoSomething()
    -- self refers to MyAddon
    self:CreateAboutPanel() -- not strictly accurate, see docs
end

-- if you are not embedding LAP
local folderName, MyAddon = ...
local LAP = LibStub("LibAboutPanel-2.0")

function MyAddon:DoSomething()
    LAP:CreateAboutPanel() -- not strictly accurate, see docs
end
```

Please be aware that capitalization in the .pkgmeta and .toc files matters, and the different slashes ("/" in .pkgmeta and "\\" in .toc files). These conventions are standards set by others. Like any other WoW addon or library, LibAboutPanel-2.0 must follow the standards.

## Compatible game versions

LibAboutPanel-2.0 should work for all official Blizzard versions of the game.

## Not a drop-in replacement

LibAboutPanel and LibAboutPanel-2.0 do more or less the same thing, but LAP2 will not replace Ackis' version just because you have it installed. As an author, you can make the choice which you prefer.

## API

You can find the [API and example here](https://github.com/Myrroddin/libaboutpanel-2.0/wiki).

## Features that are new or different than Ackis' LibAboutPanel

* More localization. LAP2 uses global strings to translate factions, locale names, etc. It also has more translatable strings than the original.
* Its API is embedded, so `MyAddOn:API()` is the norm.
* LAP2 has an API that supports AceConfig-3.0 options tables, thus the `About` panel can be displayed as a tab, part of a tree, etc.

## List of supported ToC fields

* Author
* Notes in all languages the author has translated
* Title in all languages the author has translated
* Version `@project-version@` is replaced with a translation of `Developer Build`
* X-Date or X-ReleaseDate
* X-Revision including `wowi:revision`
* X-Author-Guild
* X-Author-Faction (`Horde` or `Alliance`) translated
* X-Author-Server
* X-Website
* X-Email including X-eMail, Email, and eMail
* X-Localizations (`enUS`, `deDE`, etc) abbreviation keys which are translated themselves. Note the z not s
* X-Credits
* X-Category
* X-License `All Rights Reserved` is translated
* X-Copyright `Copyright` and `(c)` are translated

## Localization

There are several phrases and words that [need translating](https://legacy.curseforge.com/wow/addons/libaboutpanel-2-0/localization). Please help and contribute.

## Bugs and suggestions

There is a [ticket tracker](https://github.com/Myrroddin/libaboutpanel-2.0/issues) for suggesting fixes or improvements.