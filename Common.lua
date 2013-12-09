--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, ns = ...

------------------------------------------------------------------------

local L = {
	["Start Binding"] = true,
	["Stop Binding"] = true,
}
if GetLocale() == "deDE" then
	L["Start Binding"] = "Belegen beginnen"
	L["Stop Binding"] = "Belegen halten"
elseif strsub(GetLocale(), 1, 2) == "es" then
	L["Start Binding"] = "Comenzar a asignar"
	L["Stop Binding"] = "Dejar a asignar"
end
ns.L = L

------------------------------------------------------------------------

local GetKeyText
do
	local displaySubs = {
		["ALT%-"]      = "a",
		["CTRL%-"]     = "c",
		["SHIFT%-"]    = "s",
		["BUTTON"]     = "m",
		["MOUSEWHEEL"] = "w",
		["NUMPAD"]     = "n",
		["PLUS"]       = "+",
		["MINUS"]      = "-",
		["MULTIPLY"]   = "*",
		["DIVIDE"]     = "/",
		["DECIMAL"]    = ".",
	}
	function GetKeyText(key)
		if not key then
			return ""
		end
		for k, v in pairs(displaySubs) do
			key = gsub(key, k, v)
		end
		return key
	end
end
ns.GetKeyText = GetKeyText

------------------------------------------------------------------------