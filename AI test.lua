local MAJOR, MINOR = "LibAboutPanel-2.0", 114 -- bumped minor version for this revision
assert(LibStub, MAJOR .. " requires LibStub") -- LibStub is a lightweight lib loader
local AboutPanel = LibStub:NewLibrary(MAJOR, MINOR)
if not AboutPanel then return end -- skip if an equal/newer version is already loaded

-- Persistent tables so state is preserved across reloads
AboutPanel.embeds		= AboutPanel.embeds or {} -- addons this library has been embedded into
AboutPanel.aboutTable	= AboutPanel.aboutTable or {} -- cached AceConfig tables
AboutPanel.aboutFrame	= AboutPanel.aboutFrame or {} -- cached Blizzard Settings frames

-- Lua / WoW APIs
local setmetatable, tostring, rawset, pairs, strmatch = setmetatable, tostring, rawset, pairs, strmatch
local GetLocale, CreateFrame = GetLocale, CreateFrame
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata -- retrieves .toc metadata like Title, Notes, Author, etc.

-- Localization shim: if no translation exists, return the key itself
local L = setmetatable({}, {
	__index = function(tab, key)
		local value = tostring(key)
		rawset(tab, key, value)
		return value
	end
})

local locale = GetLocale()
if locale == "deDE" then
	--@localization(locale="deDE", format="lua_additive_table")@
elseif locale == "esES" or locale == "esMX" then
	--@localization(locale="esES", format="lua_additive_table")@
elseif locale == "frFR" then
	--@localization(locale="frFR", format="lua_additive_table")@
elseif locale == "itIT" then
	--@localization(locale="itIT", format="lua_additive_table")@
elseif locale == "koKR" then
	--@localization(locale="koKR", format="lua_additive_table")@
elseif locale == "ptBR" then
	--@localization(locale="ptBR", format="lua_additive_table")@
elseif locale == "ruRU" then
	--@localization(locale="ruRU", format="lua_additive_table")@
elseif locale == "zhCN" then
	--@localization(locale="zhCN", format="lua_additive_table")@
elseif locale == "zhTW" then
	--@localization(locale="zhTW", format="lua_additive_table")@
end

-- -----------------------------------------------------
-- Helper functions to standardize metadata lookups
-- -----------------------------------------------------

-- TitleCase: make "john DOE" into "John Doe"
local function TitleCase(str)
	return str and str:gsub("(%a)(%a+)", function(a, b) return a:upper() .. b:lower() end)
end

-- GetMeta: fetches metadata, respecting locale if available (e.g. "Title-frFR")
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
local function GetCategory(addon)	return GetAddOnMetadata(addon, "X-Category") end

-- Dates: some repos expand $Date$ keywords, so strip that formatting
local function GetAddOnDate(addon)
	local date = GetAddOnMetadata(addon, "X-Date") or GetAddOnMetadata(addon, "X-ReleaseDate")
	if not date then return end
	date = date:gsub("%$Date: (.-) %$", "%1")
	return date:gsub("%$LastChangedDate: (.-) %$", "%1")
end

-- Author: adds optional guild/server/faction info if defined in toc
local function GetAuthor(addon)
	local author = GetAddOnMetadata(addon, "Author")
	if not author then return end
	author = TitleCase(author)

	local server	= GetAddOnMetadata(addon, "X-Author-Server")
	local guild		= GetAddOnMetadata(addon, "X-Author-Guild")
	local faction	= GetAddOnMetadata(addon, "X-Author-Faction")

	if server then
		author = author .. " " .. L["on the %s realm"]:format(TitleCase(server)) .. "."
	end
	if guild then
		author = author .. " <" .. guild .. ">"
	end
	if faction then
		faction = TitleCase(faction)
		faction = faction:gsub("Alliance", FACTION_ALLIANCE):gsub("Horde", FACTION_HORDE)
		author = author .. " (" .. faction .. ")"
	end
	return author
end

-- Version: parses repo substitution keywords (e.g. $Revision$)
local function GetVersion(addon)
	local version = GetAddOnMetadata(addon, "Version")
	if not version then return end

	version = version
		:gsub("%.?%$Revision: (%d+) %$", " -rev.%1")
		:gsub("%.?%$Rev: (%d+) %$", " -rev.%1")
		:gsub("%.?%$LastChangedRevision: (%d+) %$", " -rev.%1")
		:gsub("r2", L["Repository"]) -- Curseforge keyword
		:gsub("wowi:revision", L["Repository"]) -- WoWInterface keyword
		:gsub("@.+", L["Developer Build"]) -- any repo dev tag

	local revision = GetAddOnMetadata(addon, "X-Project-Revision")
	if revision then version = version .. " -rev." .. revision end
	return version
end

-- License: formats "Copyright (c)" into © and normalizes case
local function GetLicense(addon)
	local license = GetAddOnMetadata(addon, "X-License") or GetAddOnMetadata(addon, "X-Copyright")
	if not license then return end

	if not (strmatch(license, "^MIT") or strmatch(license, "^GNU")) then
		license = TitleCase(license)
	end
	return (license
		:gsub("Copyright", L["Copyright"] .. " ©")
		:gsub("%([cC]%)", "©")
		:gsub("© ©", "©")
		:gsub("  ", " ")
		:gsub("[aA]ll [rR]ights [rR]eserved", L["All Rights Reserved"]))
end

-- Localization strings: map enUS/deDE etc. to Blizzard's global language constants
local localeMap = {
	["enUS"] = LFG_LIST_LANGUAGE_ENUS, ["deDE"] = LFG_LIST_LANGUAGE_DEDE,
	["frFR"] = LFG_LIST_LANGUAGE_FRFR, ["koKR"] = LFG_LIST_LANGUAGE_KOKR,
	["ruRU"] = LFG_LIST_LANGUAGE_RURU, ["itIT"] = LFG_LIST_LANGUAGE_ITIT,
	["ptBR"] = LFG_LIST_LANGUAGE_PTBR, ["zhCN"] = LFG_LIST_LANGUAGE_ZHCN,
	["zhTW"] = LFG_LIST_LANGUAGE_ZHTW, ["esES"] = LFG_LIST_LANGUAGE_ESES,
	["esMX"] = LFG_LIST_LANGUAGE_ESMX
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

-- Optional contact info
local function GetWebsite(addon)
	local site = GetAddOnMetadata(addon, "X-Website")
	return site and "|cff77ccff" .. site:gsub("https?://", "")
end

local function GetEmail(addon)
	local email = GetAddOnMetadata(addon, "X-Email") or GetAddOnMetadata(addon, "Email") or GetAddOnMetadata(addon, "eMail")
	return email and "|cff77ccff" .. email
end

-- -----------------------------------------------------
-- Shared Editbox: re-used for copying fields like email/website
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
-- Create About Panel in Interface Options (Blizzard UI)
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
	local i, labels, details = 0, {}, {}
	local function SetAboutInfo(field, text, editable)
		if not text then return end
		i = i + 1
		labels[i] = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		labels[i]:SetPoint("TOPLEFT", (i == 1 and (notes and notes_str or title_str) or labels[i-1]), "BOTTOMLEFT", i == 1 and -2 or 0, -10)
		labels[i]:SetWidth(80)
		labels[i]:SetJustifyH("RIGHT")
		labels[i]:SetText(field)

		details[i] = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		details[i]:SetPoint("TOPLEFT", labels[i], "TOPRIGHT", 4, 0)
		details[i]:SetPoint("RIGHT", frame, -16, 0)
		details[i]:SetJustifyH("LEFT")
		details[i]:SetText(text)

		if editable then
			local button = CreateFrame("Button", nil, frame)
			button:SetAllPoints(details[i])
			button.value = text
			button:SetScript("OnClick", OpenEditbox)
			button:SetScript("OnEnter", ShowTooltip)
			button:SetScript("OnLeave", HideTooltip)
		end
	end

	-- Add fields (conditionally if metadata exists)
	SetAboutInfo(L["Date"],				GetAddOnDate(addon))
	SetAboutInfo(L["Version"],			GetVersion(addon))
	SetAboutInfo(L["Author"],			GetAuthor(addon))
	SetAboutInfo(L["Category"],			GetCategory(addon))
	SetAboutInfo(L["License"],			GetLicense(addon))
	SetAboutInfo(L["Credits"],			GetCredits(addon))
	SetAboutInfo(L["Email"],			GetEmail(addon), true)
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
-- Create AceConfig-3.0 options table (alternative UI)
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

	addField(5,  "Date",			GetAddOnDate(addon))
	addField(6,  "Version",			GetVersion(addon))
	addField(7,  "Author",			GetAuthor(addon))
	addField(8,  "Category",		GetCategory(addon))
	addField(9,  "License",			GetLicense(addon))
	addField(10, "Credits",			GetCredits(addon))
	addField(11, "Email",			GetEmail(addon), true)
	addField(12, "Website",			GetWebsite(addon), true)
	addField(13, "Localizations",	GetLocalizations(addon))

	AboutPanel.aboutTable[addon] = Table
	return Table
end

-- -----------------------------------------------------
-- Embed handling: copy mixin functions into addon object
-- -----------------------------------------------------
local mixins = { "CreateAboutPanel", "AboutOptionsTable" }
function AboutPanel:Embed(target)
	for _, name in pairs(mixins) do
		target[name] = self[name]
	end
	self.embeds[target] = true
	return target
end

-- Upgrade previously embedded addons if new version loaded
for addon in pairs(AboutPanel.embeds) do
	AboutPanel:Embed(addon)
end