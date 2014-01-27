--[[--------------------------------------------------------------------
	PhanxBind
	Direct key bindings for spells and macros.
	Copyright (c) 2011-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local _, Addon = ...
local L = Addon.L
local GetKeyText = Addon.GetKeyText

PhanxBindSpells = {}

local spellToKey, keyToSpell = {}, {}
local SpellBinder = Addon:CreateBinderGroup("Spell")

function SpellBinder:SetBinding(id, key)
	--print(self.name, "SetBinding", id, key)
	if not id or not key then return end

	if spellToKey[id] then
		self:ClearBinding(id)
	end
	if keyToSpell[key] and keyToSpell[key] ~= id then
		self:ClearBinding(keyToSpell[key])
	end
	if PhanxBindMacros[key] then
		PhanxMacroBinder:ClearBinding(PhanxBindMacros[key])
	end

	spellToKey[id], keyToSpell[key] = key, id

	local spell = GetSpellInfo(id)
	SetOverrideBindingSpell(self, nil, key, spell)
	--print("BIND SPELL", spell, "->", key)

	return true
end

function SpellBinder:ClearBinding(id)
	--print(self.name, "ClearBinding", id)
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
		--print("GetButtonSpell", button:GetName(), "flyout", button.spellID, (GetSpellInfo(button.spellID)))
		return button.spellID
	end
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	if slot then
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType)
		--print("GetButtonSpell", button:GetName(), "book", id, (GetSpellInfo(id)))
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

function SpellBinder:OnEnterBinder(binder)
	if binder.isFlyout then
		SpellFlyoutButton_SetTooltip(binder:GetParent())
	else
		SpellButton_OnEnter(binder:GetParent())
	end
end

function SpellBinder:OnLeaveBinder(binder)
	GameTooltip:Hide()
end

function SpellBinder:GetBindingTarget(binder)
	return GetButtonSpell(binder:GetParent())
end

------------------------------------------------------------------------

function SpellBinder:Initialize()
	--print(self.name, "Initialize")
	for key, spell in pairs(PhanxBindSpells) do
		if type(spell) == "string" then
			local link = GetSpellLink(link)
			local id = link and strmatch(link, "spell:(%d+)")
			if id then
				PhanxBindSpells[key] = id
				print("Updated old binding:", key, "->", spell, id)
			else
				PhanxBindSpells[key] = nil
				print("Removed old binding:", key, "->", spell)
			end
		end
	end
	for key, spell in pairs(PhanxBindSpells) do
		self:SetBinding(spell, key)
	end
	PhanxBindSpells = keyToSpell

	self:ClearAllPoints()
	self:SetParent(SpellBookSpellIconsFrame)
	self:SetFrameLevel(SpellBookSpellIconsFrame:GetFrameLevel() + 1)
	self:SetPoint("BOTTOMLEFT", 94, 32)
	self:SetSize(200, 28)
	self:SetText(L["Start Binding"])

	for i = 1, SPELLS_PER_PAGE do
		local binder = self:CreateBinder(_G["SpellButton"..i])
		binder:SetFrameLevel(30)
		binder:SetID(i)
		binder.bindType = "SPELL"
		self.buttons[i] = binder
	end
end

function SpellBinder:UpdateButtons()
	--print(self.name, "UpdateButtons")
	if SpellBookFrame:IsShown() then
		for i = 1, SPELLS_PER_PAGE do
			local binder = self.buttons[i]
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
	end
	if SpellFlyout:IsShown() then
		local flyoutInBook = SpellFlyout:GetParent():GetParent() == SpellBookSpellIconsFrame
		for i = SPELLS_PER_PAGE + 1, #self.buttons do
			local binder = self.buttons[i]
			local button = binder:GetParent()
			binder:SetFrameLevel(button:GetFrameLevel() + 1)
			binder.text:SetText(GetKeyText(spellToKey[GetButtonSpell(button)]))
			if self.bindingMode and flyoutInBook then
				binder:Show()
				binder.text:SetParent(binder)
			else
				binder:Hide()
				binder.text:SetParent(button)
			end
		end
	end
end

SpellBookFrame:HookScript("OnHide", function()
	SpellBinder:StopBinding()
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
		local binder = SpellBinder.buttons[SPELLS_PER_PAGE + i]
		if not binder then
			binder = SpellBinder:CreateBinder(button)
			binder:SetFrameLevel(button:GetFrameLevel() + 1)
			binder:SetID(i)
			binder.bindType = "SPELL"
			binder.isFlyout = true
			SpellBinder.buttons[SPELLS_PER_PAGE + i] = binder
		end
		i = i + 1
	end
	SpellBinder:UpdateButtons()
end)
