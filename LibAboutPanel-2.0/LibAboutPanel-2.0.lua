--[[
LibAboutPanel-2.0: WoW Lua library for displaying addon metadata in Blizzard's Interface Options and AceConfig-3.0 tables.
Supports Classic Era, Classic, and Retail. This file contains the core implementation and helper functions.
--]]

local MAJOR, MINOR = "LibAboutPanel-2.0", 114 -- Library name and version; bump MINOR for each revision
assert(LibStub, MAJOR .. " requires LibStub") -- LibStub is a lightweight lib loader
local AboutPanel, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
if not AboutPanel then return end -- skip if an equal/newer version is already loaded
local _, localizations = ... -- get the vaarg table
local L = localizations.L -- reference to localization table

-- Persistent tables: preserve state across UI reloads and allow caching for performance
AboutPanel.embeds		= AboutPanel.embeds or {} -- Tracks addons this library has been embedded into
AboutPanel.aboutTable	= AboutPanel.aboutTable or {} -- Caches AceConfig options tables per addon
AboutPanel.aboutFrame	= AboutPanel.aboutFrame or {} -- Caches Blizzard Settings frames per addon

-- Localize frequently used Lua and WoW API functions for performance
local pairs, strmatch, GetLocale, CreateFrame = pairs, strmatch, GetLocale, CreateFrame
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata -- retrieves .toc metadata like Title, Notes, Author, etc.
local format, gsub, upper, lower = string.format, string.gsub, string.upper, string.lower

-- -----------------------------------------------------
-- Helper functions to standardize metadata lookups and parsing from .toc files
-- -----------------------------------------------------

local locale = GetLocale() -- current game client locale
-- Converts a string to title case (e.g., "john DOE" -> "John Doe")
local function TitleCase(str)
	return str and gsub(str, "(%a)(%a+)", function(a, b) return upper(a) .. lower(b) end)
end

-- Fetches metadata from the addon .toc, using localized fields if available
local function GetMeta(addon, field, localized)
	if localized and locale ~= "enUS" then
		local v = GetAddOnMetadata(addon, field .. "-" .. locale)
		if v then return v end
	end
	return GetAddOnMetadata(addon, field)
end

local function GetTitle(addon)		return GetMeta(addon, "Title", true) end
local function GetNotes(addon)		return GetMeta(addon, "Notes", true) end
local function GetCredits(addon)	return GetAddOnMetadata(addon, "X-Credits") end

-- Retrieves category field from .toc
local function GetCategory(addon)
	local category = GetAddOnMetadata(addon, "X-Category") or GetAddOnMetadata(addon, "Category")
	if not category then return end

	-- there are 25+ standard categories in WoW, map them to localized strings if possible
	category = category:gsub("[aA]ction [bB]ars", ACTIONBARS_LABEL)
	category = category:gsub("[aA]uctions", AUCTIONS)
	category = category:gsub("[bB]uffs (&|and) [dD]ebuffs", BUFFOPTIONS_LABEL)
	category = category:gsub("[cC]hat", CHAT)
	category = category:gsub("[cC]ollections", AUCTION_HOUSE_FILTER_CATEGORY_COLLECTIONS)
	category = category:gsub("[cC]ombat", COMBAT_LABEL)
	category = category:gsub("[dD]ata [bB]roker", L["Data Broker"])
	category = category:gsub("[dD]eveloper [tT]ools", L["Developer Tools"])
	category = category:gsub("[dD]ungeons (&|and) [rR]aids", L["Dungeons & Raids"])
	category = category:gsub("[eE]quipment", AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT)
	category = category:gsub("[eE]xpansion [fF]eatures", L["Expansion Features"])
	category = category:gsub("[iI]nventory", INVENTORY_TOOLTIP)
	category = category:gsub("[lL]ibraries", L["Libraries"])
	category = category:gsub("[lL]oot", LOOT_NOUN)
	-- the map and minimap replacements must be in the following order to avoid double-replacing "map" in "minimap"
	category = category:gsub("[mM]ap%s*(&|and)%s*[mM]inimap", WORLD_MAP .. " " .. QUEST_LOGIC_AND .. " " .. MINIMAP_LABEL)
	category = category:gsub("[mM]ap", WORLD_MAP)
	category = category:gsub("[mM]inimap", MINIMAP_LABEL)
	category = category:gsub("[mM]edia", L["Media"])
	category = category:gsub("[mM]iscellaneous", MISCELLANEOUS)
	category = category:gsub("[oO]ther", OTHER)
	category = category:gsub("[pP]et [bB]attles", SHOW_PET_BATTLES_ON_MAP_TEXT)
	category = category:gsub("[pP]rofessions", TRADE_SKILLS)
	category = category:gsub("[pP][vV][pP]", PVP)
	category = category:gsub("[qQ]uests", QUESTS_LABEL)
	category = category:gsub("[sS]ocial", L["Roleplay"])
	category = category:gsub("[uU][iI] [oO]verhaul", L["UI Overhaul"])
	category = category:gsub("[uU]nit [fF]rames", UNITFRAME_LABEL)
	category = category:gsub("[uU]ser [iI]nterface", BUG_CATEGORY5)
	category = category:gsub("[mM]inigames", L["Minigames"])

	return category
end

-- Parses and normalizes date fields from .toc, handling repo keyword expansion
local function GetAddOnDate(addon)
	local date = GetAddOnMetadata(addon, "X-Date") or GetAddOnMetadata(addon, "X-ReleaseDate")
	if not date then return end

	date = date:gsub("%$Date: (.-) %$", "%1")
	date = date:gsub("%$LastChangedDate: (.-) %$", "%1")
	return date
end

-- Formats author field, appending guild/server/faction info if present
local function GetAuthor(addon)
	local author = GetAddOnMetadata(addon, "Author")
	if not author then return end
	author = TitleCase(author)

	local server	= GetAddOnMetadata(addon, "X-Author-Server")
	local guild		= GetAddOnMetadata(addon, "X-Author-Guild")
	local faction	= GetAddOnMetadata(addon, "X-Author-Faction")

	if server then
		author = author .. " " .. format(L["on the %s realm"], TitleCase(server)) .. "."
	end
	if guild then
		author = author .. " <" .. guild .. ">"
	end
	if faction then
		faction = TitleCase(faction)
		faction = gsub(faction, "Alliance", FACTION_ALLIANCE)
		faction = gsub(faction, "Horde", FACTION_HORDE)
		author = author .. " (" .. faction .. ")"
	end
	return author
end

-- Parses version field, handling repo keywords and developer build tags
local function GetVersion(addon)
	local version = GetAddOnMetadata(addon, "Version")
	if not version then return end

	version = gsub(version, "%.?%$Revision: (%d+) %$", " -rev.%1")
	version = gsub(version, "%.?%$Rev: (%d+) %$", " -rev.%1")
	version = gsub(version, "%.?%$LastChangedRevision: (%d+) %$", " -rev.%1")
	version = gsub(version, "r2", L["Repository"])
	version = gsub(version, "wowi:revision", L["Repository"])
	version = gsub(version, "@.+", L["Developer Build"])

	local revision = GetAddOnMetadata(addon, "X-Project-Revision")
	if revision then version = version .. " -rev." .. revision end
	return version
end

-- Normalizes and translates license/copyright fields
local function GetLicense(addon)
	local license = GetAddOnMetadata(addon, "X-License") or GetAddOnMetadata(addon, "X-Copyright")
	if not license then return end

	if not (strmatch(license, "^MIT") or strmatch(license, "^GNU")) then
		license = TitleCase(license)
	end
	license = gsub(license, "Copyright", L["Copyright"] .. " ©")
	license = gsub(license, "%([cC]%)", "©")
	license = gsub(license, "© ©", "©")
	license = gsub(license, "  ", " ")
	license = gsub(license, "[aA]ll [rR]ights [rR]eserved", L["All Rights Reserved"])
	return license
end

-- Maps locale abbreviations to Blizzard's global language constants
local localeMap = {
	["enUS"] = LFG_LIST_LANGUAGE_ENUS, ["deDE"] = LFG_LIST_LANGUAGE_DEDE,
	["esES"] = LFG_LIST_LANGUAGE_ESES, ["esMX"] = LFG_LIST_LANGUAGE_ESMX,
	["frFR"] = LFG_LIST_LANGUAGE_FRFR, ["itIT"] = LFG_LIST_LANGUAGE_ITIT,
	["koKR"] = LFG_LIST_LANGUAGE_KOKR, ["ptBR"] = LFG_LIST_LANGUAGE_PTBR,
	["ruRU"] = LFG_LIST_LANGUAGE_RURU, ["zhCN"] = LFG_LIST_LANGUAGE_ZHCN,
	["zhTW"] = LFG_LIST_LANGUAGE_ZHTW
}
local function GetLocalizations(addon)
	local translations = GetAddOnMetadata(addon, "X-Localizations")
	if translations then
		for k, v in pairs(localeMap) do
			translations = translations:gsub(k, v)
		end
	end
	return translations
end

-- Retrieves website and email fields, formatting for display/copy
local function GetWebsite(addon)
	local site = GetAddOnMetadata(addon, "X-Website")
	return site and "|cff77ccff" .. gsub(site, "https?://", "")
end

local function GetEmail(addon)
	local email = GetAddOnMetadata(addon, "X-Email") or GetAddOnMetadata(addon, "Email") or GetAddOnMetadata(addon, "eMail")
	return email and "|cff77ccff" .. email
end

-- -----------------------------------------------------
-- Shared editbox UI for copying fields (email, website) in About panel
-- -----------------------------------------------------
local editbox = CreateFrame("EditBox", nil, nil, "InputBoxTemplate") -- WoW API: creates an input box UI element
editbox:Hide()
editbox:SetFontObject("GameFontHighlightSmall")
editbox:SetScript("OnEscapePressed", editbox.Hide)
editbox:SetScript("OnEnterPressed", editbox.Hide)
editbox:SetScript("OnEditFocusLost", editbox.Hide)
editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
editbox:SetScript("OnTextChanged", function(self)
	self:SetText(self:GetParent().value) -- always reset to original
	self:HighlightText() -- auto-select text for copy
end)
AboutPanel.editbox = editbox

local function OpenEditbox(self)
	editbox:SetParent(self)
	editbox:SetAllPoints(self)
	editbox:SetText(self.value)
	editbox:Show()
end

local function ShowTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetText(L["Click and press Ctrl-C to copy"])
end
local function HideTooltip() GameTooltip:Hide() end

-- -----------------------------------------------------
-- Creates the About panel in Blizzard's Interface Options (Settings UI)
-- -----------------------------------------------------
function AboutPanel:CreateAboutPanel(addon, parent)
	addon = addon:gsub(" ", "") -- some APIs don't like spaces in addon name
	addon = parent or addon

	local frame = AboutPanel.aboutFrame[addon]
	if frame then return frame end -- reuse cached

	frame = CreateFrame("Frame", addon.."AboutPanel", UIParent) -- UIParent makes this a global frame
	local title_str = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title_str:SetPoint("TOPLEFT", 16, -16)
	title_str:SetText((parent and GetTitle(addon) or addon) .. " - " .. L["About"])

	-- Add notes paragraph if present
	local notes = GetNotes(addon)
	local notes_str
	if notes then
		notes_str = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		notes_str:SetHeight(32)
		notes_str:SetPoint("TOPLEFT", title_str, "BOTTOMLEFT", 0, -8)
		notes_str:SetPoint("RIGHT", frame, -32, 0)
		notes_str:SetNonSpaceWrap(true)
		notes_str:SetJustifyH("LEFT")
		notes_str:SetText(notes)
	end

	-- Dynamically stack info fields
	local i = 0
	local prev_label = nil
	local function SetAboutInfo(field, text, editable)
		if not text then return end
		i = i + 1
		local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		label:SetPoint("TOPLEFT", (i == 1 and (notes and notes_str or title_str) or prev_label), "BOTTOMLEFT", i == 1 and -2 or 0, -10)
		label:SetWidth(80)
		label:SetJustifyH("RIGHT")
		label:SetText(field)
		prev_label = label

		local detail = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		detail:SetPoint("TOPLEFT", label, "TOPRIGHT", 4, 0)
		detail:SetPoint("RIGHT", frame, -16, 0)
		detail:SetJustifyH("LEFT")
		detail:SetText(text)

		if editable then
			local button = CreateFrame("Button", nil, frame)
			button:SetAllPoints(detail)
			button.value = text
			button:SetScript("OnClick", OpenEditbox)
			button:SetScript("OnEnter", ShowTooltip)
			button:SetScript("OnLeave", HideTooltip)
		end
	end

	-- Add fields (conditionally if metadata exists)
	SetAboutInfo(GAME_VERSION_LABEL,	GetVersion(addon))
	SetAboutInfo(L["Author"],			GetAuthor(addon))
	SetAboutInfo(L["Email"],			GetEmail(addon), true)
	SetAboutInfo(L["Date"],				GetAddOnDate(addon))
	SetAboutInfo(CATEGORY,				GetCategory(addon))
	SetAboutInfo(L["License"],			GetLicense(addon))
	SetAboutInfo(L["Credits"],			GetCredits(addon))
	SetAboutInfo(L["Website"],			GetWebsite(addon), true)
	SetAboutInfo(L["Localizations"],	GetLocalizations(addon))

	-- Register with Blizzard's modern Settings system (Dragonflight+)
	frame.name = not parent and addon or L["About"]
	frame.parent = parent
	Settings.RegisterCanvasLayoutCategory(frame)

	AboutPanel.aboutFrame[addon] = frame
	return frame
end

-- -----------------------------------------------------
-- Creates an AceConfig-3.0 options table for About info (alternative UI)
-- -----------------------------------------------------
function AboutPanel:AboutOptionsTable(addon)
	assert(LibStub("AceConfig-3.0"), "LibAboutPanel-2.0: API 'AboutOptionsTable' requires AceConfig-3.0", 2)
	addon = addon:gsub(" ", "")

	local Table = AboutPanel.aboutTable[addon]
	if Table then return Table end

	Table = {
		name = L["About"],
		type = "group",
		args = {
			title = {
				order = 1,
				name = "|cffe6cc80" .. (GetTitle(addon) or addon) .. "|r",
				type = "description",
				fontSize = "large",
			}
		}
	}

	-- helper to add fields
	local function addField(order, label, text, asInput)
		if not text then return end
		if asInput then
			Table.args[label] = {
				order = order,
				name = "|cffe6cc80" .. L[label] .. ": |r",
				desc = L["Click and press Ctrl-C to copy"],
				type = "input", -- AceConfig input box
				width = "full",
				get = function() return text end,
			}
		else
			Table.args[label] = {
				order = order,
				name = "|cffe6cc80" .. L[label] .. ": |r" .. text,
				type = "description",
			}
		end
	end

	-- Add optional fields
	local notes = GetNotes(addon)
	if notes then
		Table.args.blank = { order = 2, name = "", type = "description" }
		Table.args.notes = { order = 3, name = notes, type = "description", fontSize = "medium" }
	end

	addField(5,		GAME_VERSION_LABEL,	GetVersion(addon))
	addField(6,		"Author",			GetAuthor(addon))
	addField(7,		"Email",			GetEmail(addon), true)
	addField(8,		"Date",				GetAddOnDate(addon))
	addField(9,		CATEGORY,			GetCategory(addon))
	addField(10,	"License",			GetLicense(addon))
	addField(11,	"Credits",			GetCredits(addon))
	addField(12,	"Website",			GetWebsite(addon), true)
	addField(13,	"Localizations",	GetLocalizations(addon))

	AboutPanel.aboutTable[addon] = Table
	return Table
end

-- -----------------------------------------------------
-- Embeds AboutPanel API into target addon object for easy usage
-- -----------------------------------------------------
local mixins = { "CreateAboutPanel", "AboutOptionsTable" }
function AboutPanel:Embed(target)
	for _, name in pairs(mixins) do
		target[name] = self[name]
	end
	self.embeds[target] = true
	return target
end

-- Upgrades previously embedded addons if a new version of the library is loaded
for target, _ in pairs(AboutPanel.embeds) do
	AboutPanel:Embed(target)
end