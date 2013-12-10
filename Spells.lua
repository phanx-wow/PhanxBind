--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, ns = ...
local GetKeyText = ns.GetKeyText
local L = ns.L

PhanxBindSpells = {}

local spellBindButtons, spellBindFlyoutButtons = {}, {}
local spellToKey, keyToSpell = {}, {}
local SpellBinder = CreateFrame("Button", "PhanxSpellBinder", SpellBookFrame, "UIPanelButtonTemplate")

function SpellBinder:BindSpell(id, key)
	--print("BindSpell", id, key)
	if not id or not key then return end

	if spellToKey[id] then
		self:UnbindSpell(id)
	end
	if keyToSpell[key] and keyToSpell[key] ~= id then
		self:UnbindSpell(keyToSpell[key])
	end
	if PhanxBindMacros[key] then
		PhanxMacroBinder:UnbindMacro(PhanxBindMacros[key])
	end

	spellToKey[id], keyToSpell[key] = key, id

	local spell = GetSpellInfo(id)
	SetOverrideBindingSpell(self, nil, key, spell)
	--print("BIND SPELL", spell, "->", key)

	return true
end

function SpellBinder:UnbindSpell(id)
	--print("UnbindSpell", id)
	if not id then return end

	local key = spellToKey[id]
	if not key then return end

	spellToKey[id], keyToSpell[key] = nil, nil

	local spell = GetSpellInfo(id)
	SetOverrideBinding(self, nil, key, nil)
	--print("UNBIND SPELL", spell, "->", key)

	return true
end

------------------------------------------------------------------------

local function GetButtonSpell(button)
	if strmatch(button:GetName(), "^SpellFlyoutButton") then
		return button.spellID
	end
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	if slot then
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType)
		return id
	end
end

local function IsButtonPassive(button)
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	if slot then
		return IsPassiveSpell(slot, SpellBookFrame.bookType)
	end
end

local function IsButtonFlyout(button)
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	if slot then
		return slotType == "FLYOUT"
	end
end

------------------------------------------------------------------------

local CreateBinder
do
	local ignoreKeys = {
		["BUTTON1"] = true,
		["BUTTON2"] = true,
		["UNKNOWN"] = true,
		["LSHIFT"] = true,
		["LCTRL"] = true,
		["LALT"] = true,
		["RSHIFT"] = true,
		["RCTRL"] = true,
		["RALT"] = true,
	}

	local function button_OnKeyDown(self, key)
		--print(self:GetID(), "OnKeyDown", key)
		if key == "ESCAPE" then
			local spell = GetButtonSpell(self:GetParent())
			if SpellBinder:UnbindSpell(spell) then
				self.text:SetText("")
			end
		elseif not ignoreKeys[key] then
			if IsShiftKeyDown() then
				key = "SHIFT-" .. key
			end
			if IsControlKeyDown() then
				key = "CTRL-" .. key
			end
			if IsAltKeyDown() then
				key = "ALT-" .. key
			end
			local spell = GetButtonSpell(self:GetParent())
			if SpellBinder:BindSpell(spell, key) then
				self.text:SetText(GetKeyText(key) or key)
			end
		end
	end

	local function button_OnMouseDown(self, button)
		--print(self:GetID(), "OnMouseDown", button)
		if button == "LeftButton" or button == "RightButton" then
			return
		elseif button == "MiddleButton" then
			button = "BUTTON3"
		else
			button = strupper(button)
		end
		button_OnKeyDown(self, button)
	end

	local function button_OnEnter(self)
		--print(self:GetID(), "OnEnter")
		for i = 1, #spellBindButtons do
			local binder = spellBindButtons[i]
			binder:EnableKeyboard(binder == self)
		end
		for i = 1, #spellBindFlyoutButtons do
			local binder = spellBindFlyoutButtons[i]
			binder:EnableKeyboard(binder == self)
		end
		if self.isFlyout then
			SpellFlyoutButton_SetTooltip(self:GetParent())
		else
			SpellButton_OnEnter(self:GetParent())
		end
	end

	local function button_OnLeave(self)
		--print(self:GetID(), "OnLeave")
		for i = 1, #spellBindButtons do
			local binder = spellBindButtons[i]
			binder:EnableKeyboard(false)
		end
		for i = 1, #spellBindFlyoutButtons do
			local binder = spellBindFlyoutButtons[i]
			binder:EnableKeyboard(false)
		end
		GameTooltip:Hide()
	end

	local button_backdrop = {
		bgFile = "Interface\\BUTTONS\\WHITE8X8",
		tile = true,
		tileSize = 8,
	}

	function CreateBinder(parent)
		local binder = CreateFrame("Button", nil, parent)
		binder:SetAllPoints(true)
		binder:Hide()

		binder:SetBackdrop(button_backdrop)
		binder:SetBackdropColor(0, 0, 0, 0.25)

		binder:EnableMouseWheel(true)
		binder:RegisterForClicks("AnyUp", "AnyDown")

		binder:SetScript("OnEnter", button_OnEnter)
		binder:SetScript("OnLeave", button_OnLeave)
		binder:SetScript("OnHide",  button_OnLeave)

		binder:SetScript("OnKeyDown",   button_OnKeyDown)
		binder:SetScript("OnMouseDown", button_OnMouseDown)

		local highlight = binder:CreateTexture(nil, "ARTWORK")
		highlight:SetDrawLayer("HIGHLIGHT")
		highlight:SetAllPoints(true)
		highlight:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
		highlight:SetTexCoord(0.24, 0.75, 0.24, 0.75)
		binder.highlight = highlight

		local text = binder:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		text:SetPoint("TOPRIGHT")
		binder.text = text

		return binder
	end
end

------------------------------------------------------------------------

SpellBinder:RegisterEvent("PLAYER_LOGIN")
SpellBinder:SetScript("OnEvent", function(self)
	--print("Initialize")
	for key, spell in pairs(PhanxBindSpells) do
		self:BindSpell(spell, key)
	end
	PhanxBindSpells = keyToSpell

	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", 94, 32)
	self:SetHeight(28)
	self:SetWidth(200)
	self:SetText(L["Start Binding"])

	local i = 1
	while _G["SpellButton"..i] do
		local binder = CreateBinder(_G["SpellButton"..i])
		binder:SetFrameLevel(30)
		binder:SetID(i)
		binder.bindType = "SPELL"
		spellBindButtons[i] = binder
		i = i + 1
	end

	self:UnregisterAllEvents()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", function(self)
		if self.bindingMode then
			self:StopBinding()
		end
	end)
end)

function SpellBinder:StartBinding()
	self.bindingMode = true
	--print("Spellbook binding mode on.")
	self:GetHighlightTexture():SetDrawLayer("OVERLAY")
	self:SetText(L["Stop Binding"])
	self:UpdateButtons()
end

function SpellBinder:StopBinding()
	self.bindingMode = nil
	--print("Spellbook binding mode off.")
	self:GetHighlightTexture():SetDrawLayer("HIGHLIGHT")
	self:SetText(L["Start Binding"])
	self:UpdateButtons()
end

function SpellBinder:UpdateButtons()
	if not SpellBookFrame:IsShown() then
		for i = 1, #spellBindFlyoutButtons do
			local binder = spellBindFlyoutButtons[i]
			binder:Hide()
			binder.text:SetParent(binder)
		end
		return
	end
	--print("UpdateButtons")
	for i = 1, #spellBindButtons do
		local binder = spellBindButtons[i]
		local button = binder:GetParent()
		binder.text:SetText(GetKeyText(spellToKey[GetButtonSpell(button)]))
		if self.bindingMode and not IsButtonPassive(button) and not IsButtonFlyout(button) then
			binder:Show()
			binder.text:SetParent(binder)
		else
			binder:Hide()
			binder.text:SetParent(button)
		end
	end
	if not SpellFlyout:IsShown() or SpellFlyout:GetParent():GetParent() ~= SpellBookSpellIconsFrame then
		return
	end
	for i = 1, #spellBindFlyoutButtons do
		local binder = spellBindFlyoutButtons[i]
		local button = binder:GetParent()
		if not button:IsShown() then
			break
		end
		binder:SetFrameLevel(button:GetFrameLevel() + 1)
		binder.text:SetText(GetKeyText(spellToKey[GetButtonSpell(button)]))
		if SpellBinder.bindingMode then
			binder:Show()
			binder.text:SetParent(binder)
		else
			binder:Hide()
			binder.text:SetParent(button)
		end
	end
end

SpellBinder:SetScript("OnClick", function(self, button)
	if self.bindingMode then
		self:StopBinding()
	else
		self:StartBinding()
	end
end)

hooksecurefunc("SpellBookFrame_UpdateSpells", function()
	if not SpellBookFrame:IsVisible() then
		return
	end
	--print("SpellBookFrame_UpdateSpells")
	SpellBinder:UpdateButtons()
end)

hooksecurefunc(SpellFlyout, "Toggle", function()
	if not SpellFlyout:IsVisible() then
		return
	end
	--print("SpellFlyout:Toggle")
	local i = 1
	while _G["SpellFlyoutButton"..i] do
		local button = _G["SpellFlyoutButton"..i]
		local binder = spellBindFlyoutButtons[i]
		if not binder then
			binder = CreateBinder(button)
			binder:SetFrameLevel(button:GetFrameLevel() + 1)
			binder:SetID(i)
			binder.bindType = "SPELL"
			binder.isFlyout = true
			spellBindFlyoutButtons[i] = binder
		end
		i = i + 1
	end
	SpellBinder:UpdateButtons()
end)

SpellBookFrame:HookScript("OnHide", function()
	if SpellBinder.bindingMode then
		SpellBinder:StopBinding()
	end
end)
