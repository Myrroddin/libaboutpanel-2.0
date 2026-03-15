-- get the vaargs passed to the whole addon
local _, namespace = ...

-- Localization shim: returns the key itself if no translation exists.
-- This allows the library to function even if translations are missing.
local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

namespace.L = L

L["About"] = true
L["All Rights Reserved"] = true
L["Author"] = true
L["Click and press Ctrl-C to copy"] = true
L["Copyright"] = true
L["Credits"] = true
L["Date"] = true
L["Developer Build"] = true
L["Email"] = true
L["License"] = true
L["Localizations"] = true
L["on the %s realm"] = true
L["Repository"] = true
L["Website"] = true