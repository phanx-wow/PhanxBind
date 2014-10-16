--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info22653-PhanxBind.html
	http://www.curse.com/addons/wow/phanxbind
----------------------------------------------------------------------]]
-- TODO: Save bindings for global macros on a global basis.

local ADDON, Addon = ...
local L = Addon.L
local GetKeyText = Addon.GetKeyText

PhanxBindMacros = {}

local macroToKey, keyToMacro = {}, {}
local MacroBinder = Addon:CreateBinderGroup("Macro")

function MacroBinder:SetBinding(macro, key)
	--print(self.name, "SetBinding", macro, key)
	if not macro or not key then return end

	if macroToKey[macro] then
		self:ClearBinding(macro)
	end
	if keyToMacro[key] and keyToMacro[key] ~= macro then
		self:ClearBinding(keyToMacro[key])
	end
	if PhanxBindSpells[key] then
		PhanxSpellBinder:ClearBinding(PhanxBindSpells[key])
	end

	macroToKey[macro], keyToMacro[key] = key, macro
	SetOverrideBindingMacro(self, nil, key, macro)
	--print("BIND MACRO", macro, "->", key)

	return true
end

function MacroBinder:ClearBinding(macro)
	--print(self.name, "ClearBinding", macro)
	if not macro then return end

	local key = macroToKey[macro]
	if not key then return end

	macroToKey[macro], keyToMacro[key] = nil, nil
	SetOverrideBinding(self, nil, key, nil)
	--print("UNBIND MACRO", macro, "->", key)

	return true
end

------------------------------------------------------------------------

function MacroBinder:GetBindingTarget(binder)
	--print(self.name, "GetBindingTarget", binder:GetID(), (GetMacroInfo(MacroFrame.macroBase + binder:GetID())))
	local name, icon, body = GetMacroInfo(MacroFrame.macroBase + binder:GetID())
	return name
end

------------------------------------------------------------------------

function MacroBinder:Initialize()
	--print(self.name, "Initialize")
	local saved = PhanxBindMacros
	for key, macro in pairs(saved) do
		if GetMacroIndexByName(macro) > 0 then
			-- Don't bind macros that don't exist.
			self:SetBinding(macro, key)
		else
			--print("Macro not found:", macro)
			self.missing = self.missing or {}
			self.missing[key] = macro
		end
	end
	PhanxBindMacros = keyToMacro

	if self.missing then
		self:StartQueue("Initialize")
	end

	if MacroFrame then
		self:ADDON_LOADED("ADDON_LOADED", "Blizzard_MacroUI")
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end

function MacroBinder:StartQueue(event)
	--print(self.name, "StartQueue", event)
	if not self.queue then
		function self.queue()
			if not self.missing then return end
			for key, macro in pairs(self.missing) do
				--print("Looking for missing macro:", macro)
				if GetMacroIndexByName(macro) > 0 and not keyToMacro[key] and not macroToKey[macro] then
					--print("Found it!")
					self:SetBinding(macro, key)
					self.missing[key] = nil
				else
					--print("Still missing!")
				end
			end
			if next(self.missing) and self.failures <= 5 then
				--print("Failures:", self.failures, "/", 5)
				self.failures = self.failures + 1
				C_Timer.After(1, self.queue)
			else
				if self.failures > 5 then
					--print("Too many failures, giving up.")
					for key, macro in pairs(self.missing) do
						print("Removed binding \"" .. key .. "\" for missing macro \"" .. macro .."\"")
					end
				else
					--print("No more missing macros!")
				end
				self.queue = nil
				self.failures = nil
				self.missing = nil
				self:UnregisterEvent("PLAYER_ALIVE")
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
				self:UnregisterEvent("VARIABLES_LOADED")
				self.PLAYER_ALIVE = nil
				self.PLAYER_ENTERING_WORLD = nil
				self.VARIABLES_LOADED = nil
			end
		end
	end

	self.PLAYER_ALIVE = self.StartQueue
	self.PLAYER_ENTERING_WORLD = self.StartQueue
	self.VARIABLES_LOADED = self.StartQueue

	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("VARIABLES_LOADED")

	self.failures = 0
	C_Timer.After(1, self.queue)
end

function MacroBinder:ADDON_LOADED(event, addon)
	if not MacroFrame then
		return
	end
	self:UnregisterEvent(event)
	--print(self.name, "ADDON_LOADED")

	MacroExitButton:SetWidth(70)
	MacroNewButton:SetWidth(70)
	MacroNewButton:SetPoint("BOTTOMRIGHT", -72, 4)

	self:ClearAllPoints()
	self:SetParent(MacroFrame)
	self:SetFrameLevel(MacroFrame:GetFrameLevel() + 1)
	self:SetPoint("BOTTOMLEFT", 81, 4)
	self:SetHeight(22)
	self:SetWidth(118)
	self:SetText(L["Start Binding"])

	for i = 1, max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS) do
		--print(self.name, "CreateBinder", "MacroButton"..i)
		local binder = self:CreateBinder(_G["MacroButton"..i])
		binder:SetFrameLevel(30)
		binder:SetID(i)
		binder.bindType = "MACRO"
		self.buttons[i] = binder
	end

	hooksecurefunc("MacroFrame_Update", function()
		if not MacroFrame:IsVisible() then
			return
		end
		--print("MacroFrame_Update")
		self:UpdateButtons()
	end)

	MacroFrame:HookScript("OnHide", function()
		self:StopBinding()
	end)
end

function MacroBinder:UpdateButtons()
	if not MacroFrame or not MacroFrame:IsVisible() then
		return
	end
	--print(self.name, "UpdateButtons")
	for i = 1, #self.buttons do
		local binder = self.buttons[i]
		local button = binder:GetParent()
		binder.text:SetText(GetKeyText(macroToKey[self:GetBindingTarget(button)]))
		if self.bindingMode and button:IsEnabled() then
			binder:Show()
			binder.text:SetParent(binder)
		else
			binder:Hide()
			binder.text:SetParent(button)
		end
	end
end

hooksecurefunc("DeleteMacro", function(id)
	-- Loop through the bound macros, find the one that doesn't exist,
	-- and unbind it.
	for macro, key in pairs(macroToKey) do
		if GetMacroIndexByName(macro) == 0 then
			--print(self.name, "DeleteMacro", macro)
			MacroBinder:ClearBinding(macro)
			break
		end
	end
end)

hooksecurefunc("EditMacro", function(id, name, icon, body, isLocal, isCharacter)
	-- Loop through the bound macros, find the one that doesn't exist,
	-- unbind it, and rebind that key to the new name.
	for macro, key in pairs(macroToKey) do
		if GetMacroIndexByName(macro) == 0 then
			--print(self.name, "EditMacro", macro, "=>", name)
			MacroBinder:ClearBinding(macro)
			MacroBinder:SetBinding(name, key)
			break
		end
	end
end)