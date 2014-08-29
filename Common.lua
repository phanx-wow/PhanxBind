--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info22653-PhanxBind.html
	http://www.curse.com/addons/wow/phanxbind
----------------------------------------------------------------------]]

local ADDON, Addon = ...

------------------------------------------------------------------------

local L = {
	["Start Binding"]  = "Start Binding",
	["Stop Binding"]   = "Stop Binding",
}
if GetLocale() == "deDE" then
	L["Start Binding"] = "Zuweisen"
	L["Stop Binding"]  = "Halten"
elseif strsub(GetLocale(), 1, 2) == "es" then
	L["Start Binding"] = "Asignar"
	L["Stop Binding"]  = "Dejar"
elseif GetLocale() == "frFR" then
	L["Start Binding"] = "Associer"
	L["Stop Binding"]  = "Arrêter"
elseif GetLocale() == "itIT" then
	L["Start Binding"] = "Assegnare"
	L["Stop Binding"]  = "Smettere"
elseif GetLocale() == "ptBR" then
	L["Start Binding"] = "Vincular"
	L["Stop Binding"]  = "Parar"
elseif GetLocale() == "ruRU" then
	L["Start Binding"] = "назначения"
	L["Stop Binding"]  = "Прекратить"
end
Addon.L = L

------------------------------------------------------------------------

local GetKeyText
do
	local displaySubs = {
		["ALT%-"]      = "a",
		["CTRL%-"]     = "c",
		["SHIFT%-"]    = "s",
		["BUTTON"]     = "m",
		["MOUSEWHEELUP"]   = "wU",
		["MOUSEWHEELDOWN"] = "wD",
		["INSERT"]     = "Ins",
		["DELETE"]     = "Del",
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
	Addon.GetKeyText = GetKeyText
end

------------------------------------------------------------------------

do
	local ignoreKeys = {
		["LALT"] = true,
		["LCTRL"] = true,
		["LSHIFT"] = true,
		["RALT"] = true,
		["RCTRL"] = true,
		["RSHIFT"] = true,
		["UNKNOWN"] = true,
	}

	local ignoreKeysNoMod = {
		["BUTTON1"] = true,
		["BUTTON2"] = true,
	}

	local buttonToKey = {
		["LeftButton"] = "BUTTON1",
		["RightButton"] = "BUTTON2",
		["MiddleButton"] = "BUTTON3",
	}

	local function OnKeyDown(self, key)
		--print(self.owner.name, self:GetParent():GetName(), "OnKeyDown", key)
		if key == "ESCAPE" then
			local target = self.owner:GetBindingTarget(self)
			if self.owner:ClearBinding(target) then
				self.text:SetText("")
			end
		elseif not ignoreKeys[key] and (not ignoreKeysNoMod[key] or IsModifierKeyDown()) then
			if IsShiftKeyDown() then
				key = "SHIFT-" .. key
			end
			if IsControlKeyDown() then
				key = "CTRL-" .. key
			end
			if IsAltKeyDown() then
				key = "ALT-" .. key
			end
			local target = self.owner:GetBindingTarget(self)
			if self.owner:SetBinding(target, key) then
				self.text:SetText(GetKeyText(key) or key)
				self.owner:UpdateButtons()
			end
		end
	end

	local function OnMouseDown(self, button)
		--print(self.owner.name, self:GetParent():GetName(), "OnMouseDown", button)
		OnKeyDown(self, buttonToKey[button] or strupper(button))
	end

	local function OnMouseWheel(self, delta)
		--print(self.owner.name, self:GetParent():GetName(), "OnMouseWheel", delta)
		OnKeyDown(self, delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN")
	end

	local function OnEnter(self)
		--print(self.owner.name, self:GetParent():GetName(), "OnEnter")
		for i = 1, #self.owner.buttons do
			local binder = self.owner.buttons[i]
			binder:EnableKeyboard(binder == self)
		end
		local parent = self:GetParent()
		local script = parent:GetScript("OnEnter")
		if script then
			script(parent)
		end
	end

	local function OnLeave(self)
		--print(self.owner.name, self:GetParent():GetName(), "OnLeave")
		for i = 1, #self.owner.buttons do
			local binder = self.owner.buttons[i]
			binder:EnableKeyboard(false)
		end
		local parent = self:GetParent()
		local script = parent:GetScript("OnLeave")
		if script then
			script(parent)
		end
	end

	local BACKDROP = { bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8 }

	function CreateBinder(owner, parent)
		--print(owner.name, "CreateBinder", parent:GetName())

		local binder = CreateFrame("Button", nil, parent)
		binder:SetAllPoints(true)
		binder:Hide()

		binder:SetBackdrop(BACKDROP)
		binder:SetBackdropColor(0, 0, 0, 0.25)

		binder:EnableMouseWheel(true)
		binder:RegisterForClicks("AnyUp", "AnyDown")

		binder:SetScript("OnEnter", OnEnter)
		binder:SetScript("OnLeave", OnLeave)
		binder:SetScript("OnHide",  OnLeave)

		binder:SetScript("OnKeyDown",   OnKeyDown)
		binder:SetScript("OnMouseDown", OnMouseDown)
		binder:SetScript("OnMouseWheel", OnMouseWheel)

		local highlight = binder:CreateTexture(nil, "ARTWORK")
		highlight:SetDrawLayer("HIGHLIGHT")
		highlight:SetAllPoints(true)
		highlight:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
		highlight:SetTexCoord(0.24, 0.75, 0.24, 0.75)
		binder.highlight = highlight

		local text = binder:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		text:SetPoint("TOPRIGHT")
		binder.text = text

		binder.owner = owner
		binder.parent = parent

		return binder
	end
end

------------------------------------------------------------------------

local function StartBinding(self)
	if self.bindingMode or InCombatLockdown() then return end
	self.bindingMode = true
	--print(self.name, "binding mode on.")
	self:GetHighlightTexture():SetDrawLayer("OVERLAY")
	self:SetText(L["Stop Binding"])
	self:UpdateButtons()
end

local function StopBinding(self)
	if not self.bindingMode then return end
	self.bindingMode = nil
	--print(self.name, "binding mode off.")
	self:GetHighlightTexture():SetDrawLayer("HIGHLIGHT")
	self:SetText(L["Start Binding"])
	self:UpdateButtons()
end

local function IsBinding(self)
	return self.bindingMode
end

local function OnClick(self, button)
	if self.bindingMode then
		self:StopBinding()
	else
		self:StartBinding()
	end
end

local function noop() end

function Addon:CreateBinderGroup(name)
	local f = CreateFrame("Button", "Phanx"..name.."Binder", UIParent, "UIPanelButtonTemplate")
	f:RegisterEvent("PLAYER_LOGIN")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			self:UnregisterEvent(event)
			return self:Initialize()
		elseif event == "PLAYER_REGEN_DISABLED" then
			return self:StopBinding()
		else
			return self[event](self, event, ...)
		end
	end)

	f:SetText(L["Start Binding"])
	f:SetScript("OnClick", OnClick)

	f.buttons = {}
	f.name = name

	f.CreateBinder = CreateBinder
	f.IsBinding = IsBinding
	f.StartBinding = StartBinding
	f.StopBinding = StopBinding

	-- These should be overwritten.
	f.Initialize = noop
	f.SetBinding = noop
	f.ClearBinding = noop
	f.GetBindingTarget = noop
	f.UpdateButtons = noop

	return f
end

------------------------------------------------------------------------