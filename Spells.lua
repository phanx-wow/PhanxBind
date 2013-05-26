PhanxBindSpells = {}

local spellBindButtons = {}
local spellToKey, keyToSpell = {}, {}
local SpellBinder = CreateFrame("Button", "PhanxSpellBinder", SpellBookFrame, "UIPanelButtonTemplate")

function SpellBinder:BindSpell(spell, key)
	--print("BindSpell", spell, key)
	if not spell or not key then return end
	if spellToKey[spell] then
		self:UnbindSpell(spell)
	end
	if keyToSpell[key] and keyToSpell[key] ~= spell then
		self:UnbindSpell(keyToSpell[key])
	end
	spellToKey[spell], keyToSpell[key] = key, spell
	SetOverrideBinding(self, nil, key, "SPELL "..spell)
	--print("BIND SPELL", spell, "->", key)
	return true
end

function SpellBinder:UnbindSpell(spell)
	--print("UnbindSpell", spell)
	if not spell then return end
	local key = spellToKey[spell]
	if not key then return end
	spellToKey[spell], keyToSpell[key] = nil, nil
	SetOverrideBinding(self, nil, key, nil)
	--print("UNBIND SPELL", spell, "->", key)
	return true
end

local function GetButtonSpell(button)
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	return (GetSpellBookItemName(slot, SpellBookFrame.bookType))
end

local function IsButtonPassive(button)
	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(button)
	return IsPassiveSpell(slot, SpellBookFrame.bookType)
end

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
	end

	local function button_OnLeave(self)
		--print(self:GetID(), "OnLeave")
		for i = 1, #spellBindButtons do
			local binder = spellBindButtons[i]
			binder:EnableKeyboard(false)
		end
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
	local saved = PhanxBindSpells
	for key, spell in pairs(saved) do
		self:BindSpell(spell, key)
	end
	PhanxBindSpells = keyToSpell

	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", 94, 32)
	self:SetHeight(28)
	self:SetWidth(128)
	self:SetText("Start Binding")

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
	self:SetScript("OnEvent", function()
		if self.bindingMode then
			self:StopBinding()
		end
	end)
end)

function SpellBinder:StartBinding()
	self.bindingMode = true
	print("Spellbook binding mode on.")
	self:GetHighlightTexture():SetDrawLayer("OVERLAY")
	self:SetText("Stop Binding")
	self:UpdateButtons()
end

function SpellBinder:StopBinding()
	self.bindingMode = nil
	print("Spellbook binding mode off.")
	self:GetHighlightTexture():SetDrawLayer("HIGHLIGHT")
	self:SetText("Start Binding")
	self:UpdateButtons()
end

function SpellBinder:UpdateButtons()
	if not SpellBookFrame:IsVisible() then
		return
	end
	--print("UpdateButtons")
	for i = 1, #spellBindButtons do
		local binder = spellBindButtons[i]
		local button = binder:GetParent()
		binder.text:SetText(GetKeyText(spellToKey[GetButtonSpell(button)]))
		if self.bindingMode and not IsButtonPassive(button) then
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

SpellBookFrame:HookScript("OnHide", function()
	if self.bindingMode then
		self:StopBinding()
	end
end)
