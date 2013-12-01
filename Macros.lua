-- TODO: Save bindings for global macros on a global basis.

PhanxBindMacros = {}

local macroBindButtons = {}
local macroToKey, keyToMacro = {}, {}
local MacroBinder = CreateFrame("Button", "PhanxMacroBinder", UIParent, "UIPanelButtonTemplate")

_MTK, _KTM = macroToKey, keyToMacro

function MacroBinder:BindMacro(macro, key)
	--print("BindMacro", macro, key)
	if not macro or not key then return end
	if macroToKey[macro] then
		self:UnbindMacro(macro)
	end
	if keyToMacro[key] and keyToMacro[key] ~= macro then
		self:UnbindMacro(keyToMacro[key])
	end
	macroToKey[macro], keyToMacro[key] = key, macro
	SetOverrideBinding(self, nil, key, "MACRO "..macro)
	--print("BIND MACRO", macro, "->", key)
	return true
end

function MacroBinder:UnbindMacro(macro)
	--print("UnbindMacro", macro)
	if not macro then return end
	local key = macroToKey[macro]
	if not key then return end
	macroToKey[macro], keyToMacro[key] = nil, nil
	SetOverrideBinding(self, nil, key, nil)
	--print("UNBIND MACRO", macro, "->", key)
	return true
end

local function GetButtonMacro(button)
	local name, icon, body = GetMacroInfo(MacroFrame.macroBase + button:GetID())
	return name
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
		["LSHIFT"] = true,
		["LCTRL"] = true,
		["LALT"] = true,
		["RSHIFT"] = true,
		["RCTRL"] = true,
		["RALT"] = true,
		["UNKNOWN"] = true,
	}

	local function button_OnKeyDown(self, key)
		--print(self:GetID(), "OnKeyDown", key)
		if key == "ESCAPE" then
			local macro = GetButtonMacro(self:GetParent())
			if MacroBinder:UnbindMacro(macro) then
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
			local macro = GetButtonMacro(self:GetParent())
			if MacroBinder:BindMacro(macro, key) then
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
		for i = 1, #macroBindButtons do
			local binder = macroBindButtons[i]
			binder:EnableKeyboard(binder == self)
		end
	end

	local function button_OnLeave(self)
		--print(self:GetID(), "OnLeave")
		for i = 1, #macroBindButtons do
			local binder = macroBindButtons[i]
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

MacroBinder:RegisterEvent("PLAYER_LOGIN")
MacroBinder:SetScript("OnEvent", function(self)
	--print("Initialize")
	local saved = PhanxBindMacros
	for key, macro in pairs(saved) do
		if GetMacroIndexByName(macro) > 0 then
			-- Don't bind macros that don't exist.
			self:BindMacro(macro, key)
		end
	end
	PhanxBindMacros = keyToMacro

	if not MacroFrame then
		self:RegisterEvent("ADDON_LOADED")
		return
	end

	MacroExitButton:SetWidth(70)
	MacroNewButton:SetWidth(70)
	MacroNewButton:SetPoint("BOTTOMRIGHT", -72, 4)

	self:SetParent(MacroFrame)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", 81, 4)
	self:SetHeight(22)
	self:SetWidth(118)
	self:SetText("Start Binding")

	local i = 1
	while _G["MacroButton"..i] do
		local binder = CreateBinder(_G["MacroButton"..i])
		binder:SetFrameLevel(30)
		binder:SetID(i)
		binder.bindType = "MACRO"
		macroBindButtons[i] = binder
		i = i + 1
	end

	hooksecurefunc("MacroFrame_Update", function()
		if not MacroFrame:IsVisible() then
			return
		end
		--print("MacroFrame_Update")
		MacroBinder:UpdateButtons()
	end)

	MacroFrame:HookScript("OnHide", function()
		if MacroBinder.bindingMode then
			MacroBinder:StopBinding()
		end
	end)

	self:UnregisterAllEvents()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:SetScript("OnEvent", function(self)
		if self.bindingMode then
			self:StopBinding()
		end
	end)
end)

function MacroBinder:StartBinding()
	self.bindingMode = true
	print("Macro binding mode on.")
	self:GetHighlightTexture():SetDrawLayer("OVERLAY")
	self:SetText("Stop Binding")
	self:UpdateButtons()
end

function MacroBinder:StopBinding()
	self.bindingMode = nil
	print("Macro binding mode off.")
	self:GetHighlightTexture():SetDrawLayer("HIGHLIGHT")
	self:SetText("Start Binding")
	self:UpdateButtons()
end

function MacroBinder:UpdateButtons()
	if not MacroFrame:IsVisible() then
		return
	end
	--print("UpdateButtons")
	for i = 1, #macroBindButtons do
		local binder = macroBindButtons[i]
		local button = binder:GetParent()
		binder.text:SetText(GetKeyText(macroToKey[GetButtonMacro(button)]))
		if self.bindingMode and button:IsEnabled() then
			binder:Show()
			binder.text:SetParent(binder)
		else
			binder:Hide()
			binder.text:SetParent(button)
		end
	end
end

MacroBinder:SetScript("OnClick", function(self, button)
	if self.bindingMode then
		self:StopBinding()
	else
		self:StartBinding()
	end
end)

hooksecurefunc("DeleteMacro", function(id)
	-- Loop through the bound macros, find the one that doesn't exist,
	-- and unbind it.
	for macro, key in pairs(macroToKey) do
		if GetMacroIndexByName(macro) == 0 then
			print("DeleteMacro", macro)
			self:UnbindMacro(macro)
			break
		end
	end
end)

hooksecurefunc("EditMacro", function(id, name, icon, body, ...)
	-- Loop through the bound macros, find the one that doesn't exist,
	-- unbind it, and rebind that key to the new name.
	for macro, key in pairs(macroToKey) do
		if GetMacroIndexByName(macro) == 0 then
			print("EditMacro", macro, "=>", name)
			self:UnbindMacro(macro)
			self:BindMacro(name, key)
			break
		end
	end
end)