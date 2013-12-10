--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, ns = ...

------------------------------------------------------------------------

local L = {
	["Start Binding"]  = "Start Binding",
	["Stop Binding"]   = "Stop Binding",
}
if GetLocale() == "deDE" then
	L["Start Binding"] = "Zuweisen beginnen"
	L["Stop Binding"]  = "Zuweisen halten"
elseif strsub(GetLocale(), 1, 2) == "es" then
	L["Start Binding"] = "Comienzar asignar"
	L["Stop Binding"]  = "Dejar asignar"
elseif GetLocale() == "frFR" then
	L["Start Binding"] = "Commencer associer"
	L["Stop Binding"]  = "Arrêter associer"
elseif GetLocale() == "itIT" then
	L["Start Binding"] = "Inizia assegnare"
	L["Stop Binding"]  = "Smetti assegnare"
elseif GetLocale() == "ptBR" then
	L["Start Binding"] = "Começar a vincular"
	L["Stop Binding"]  = "Parar de vincular"
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