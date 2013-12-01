function ApplyMyBindings(silent)
	ClearAllBindings()

	-- Movement
	SetBinding("E", "MOVEFORWARD")
	SetBinding("CTRL-E", "TOGGLEAUTORUN")
	SetBinding("BUTTON4", "TOGGLEAUTORUN")
	SetBinding("CTRL-SHIFT-E", "TOGGLERUN")
	SetBinding("S", "MOVEBACKWARD")
	SetBinding("SHIFT-S", "SITORSTAND")
	SetBinding("A", "STRAFELEFT")
	SetBinding("SHIFT-A", "TURNLEFT")
	SetBinding("D", "STRAFERIGHT")
	SetBinding("SHIFT-D", "TURNRIGHT")
	SetBinding("SPACE", "JUMP")

	-- Chat
	SetBinding("ENTER", "OPENCHAT")
	SetBinding("/", "OPENCHATSLASH")
	SetBinding("SHIFT-R", "REPLY")

	-- Actions
	SetBinding("SHIFT-UP", "PREVIOUSACTIONPAGE")
	SetBinding("SHIFT-MOUSEWHEELUP", "PREVIOUSACTIONPAGE")
	SetBinding("SHIFT-DOWN", "NEXTACTIONPAGE")
	SetBinding("SHIFT-MOUSEWHEELDOWN", "NEXTACTIONPAGE")

	-- Targeting
	SetBinding("TAB", "TARGETNEARESTENEMY")
	SetBinding("SHIFT-TAB", "TARGETNEARESTFRIEND")

	-- Attacking
	SetBinding("T", "STARTATTACK")
	SetBinding("SHIFT-T", "ASSISTTARGET")
	SetBinding("ALT-T", "INTERACTTARGET")

	-- Nameplates
	SetBinding("SHIFT-V", "NAMEPLATES")
	SetBinding("CTRL-V", "FRIENDNAMEPLATES")

	-- UI Panels
	SetBinding("ESCAPE", "TOGGLEGAMEMENU")
	SetBinding("B", "OPENALLBAGS")
	SetBinding("M", "TOGGLEWORLDMAP")
	SetBinding("SHIFT-M", "TOGGLEBATTLEFIELDMINIMAP")
	SetBinding("CTRL-M", "TOGGLEENCOUNTERJOURNAL")
	SetBinding("ALT-SHIFT-M", "TOGGLEWORLDSTATESCORES")
	SetBinding("F6", "TOGGLECHARACTER0")
	SetBinding("F7", "TOGGLESPELLBOOK")
	SetBinding("SHIFT-F7", "TOGGLEMOUNTJOURNAL")
	SetBinding("CTRL-F7", "TOGGLECOMPANIONJOURNAL")
	SetBinding("F8", "TOGGLETALENTS")
	SetBinding("F9", "TOGGLEQUESTLOG")
	SetBinding("F10", "TOGGLESOCIAL")
	SetBinding("SHIFT-F10", "TOGGLEGUILDTAB")
	SetBinding("F11", "TOGGLELFGPARENT")
	SetBinding("SHIFT-F11", "TOGGLECHARACTER4")
	SetBinding("F12", "TOGGLEACHIEVEMENT")

	-- UI Toggles
	SetBinding("ALT-Z", "TOGGLEUI")
	SetBinding("CTRL-R", "TOGGLEFPS")
	SetBinding("PRINTSCREEN", "SCREENSHOT")

	-- Camera
	SetBinding("MOUSEWHEELUP", "CAMERAZOOMIN")
	SetBinding("MOUSEWHEELDOWN", "CAMERAZOOMOUT")

	-- Vehicle Aim
	SetBinding("CTRL-MOUSEWHEELUP", "VEHICLEAIMUP")
	SetBinding("CTRL-MOUSEWHEELDOWN", "VEHICLEAIMDOWN")

	-- Addons
	SetBinding("`",				"CLICK Squire2Button:LeftButton")
	SetBinding("SHIFT-B",		"BAGNON_BANK_TOGGLE")
	SetBinding("ALT-CTRL-F",	"GOFISH_TOGGLE")
	SetBinding("ALT-SHIFT-F",	"HYDRA_FOLLOW")
	SetBinding("CTRL-F",		"HYDRA_FOLLOW_ME")
	SetBinding("I",				"EXAMINER_TARGET")
	SetBinding("ALT-I",			"EXAMINER_MOUSEOVER")
	SetBinding("ALT-SHIFT-L",	"CLICK LevelFlightButton:LeftButton")
	SetBinding("ALT-N",			"NOTEBOOK_PANEL")
	SetBinding("ALT-CTRL-R",	"RECOUNT_TOGGLE_MAIN")
--	SetBinding("ALT-X",			"CLICK CancelMyBuffsButton1:LeftButton")

	if not silent then
		print("Bindings applied.")
	end
end

function ApplyMyOverrideBindings(silent)
	local _, c = UnitClass("player")
	local _, r = UnitRace("player")
	local ob = {
		["ALT-Q"] = "MACRO QuestItem",
		["ALT-`"] = "ITEM Hearthstone",
	}

	-- Racial Abilities
	if r == "BloodElf" then
		ob["NUMPADMINUS"] = "SPELL Arcane Torrent"
	elseif r == "Orc" then
		ob["NUMPADMINUS"] = "SPELL Blood Fury"
	elseif r == "Tauren" then
		ob["NUMPADMINUS"] = "SPELL War Stomp"
	elseif r == "Troll" then
		ob["NUMPADMINUS"] = "SPELL Berserking"
	end

	-- Class Abilities
	if c == "DRUID" then
		-- Shapeshift Forms
		ob["F1"] = "MACRO Bear"
		ob["F2"] = "MACRO Aquatic"
		ob["F3"] = "MACRO Cat"
		ob["F4"] = "MACRO Travel"
		ob["F5"] = "MACRO Flight"

		ob["C"]  = "MACRO Cure"
		ob["G"]  = "MACRO Interrupt"
		ob["Q"]  = "MACRO Taunt"
		ob["W"]  = "MACRO Fire"
		ob["NUMPAD0"] = "MACRO Power"

	elseif c == "MONK" then
		ob["C"] = "MACRO Cure"
		ob["Q"] = "SPELL Roll"

	elseif c == "SHAMAN" then
		ob["C"] = "MACRO Cure"
		ob["W"] = "MACRO Shield"
		ob["X"] = "MACRO Hex"
		ob["Z"] = "MACRO Bind"

		ob["ALT-`"]   = "MACRO Home"
		ob["NUMPAD0"] = "MACRO Power"
		ob["NUMPADDECIMAL"] = "MACRO Defend"

		ob["NUMPADDIVIDE"] = "SPELL Earth Elemental Totem"
		ob["NUMPADMULTIPLY"] = "SPELL Fire Elemental Totem"
--[[
		ob["G"] = "SPELL Wind Shear"
		ob["O"] = "SPELL Far Sight"
		ob["P"] = "SPELL Water Walking"
		ob["CTRL-`"] = "SPELL Ghost Wolf"
		ob["F1"] = "SPELL Earthbind Totem"
		ob["F2"] = "SPELL Searing Totem"
		ob["F3"] = "SPELL Healing Tide Totem"
		ob["F4"] = "SPELL Stormlash Totem"
		ob["F5"] = "SPELL Totemic Recall"
		ob["NUMPADPLUS"] = "SPELL Bloodlust"
		ob["NUMPAD1"] = "SPELL Ascendance"
		ob["NUMPAD2"] = "SPELL Spirit Walk"
		ob["NUMPAD3"] = "SPELL Astral Shift"
]]
	elseif c == "PALADIN" then
		ob["G"] = "MACRO Interrupt"
--[[
		ob["Q"] = "SPELL Reckoning"

		ob["F1"] = "SPELL Righteous Fury"
		ob["F2"] = "SPELL Seal of Truth"
		ob["F3"] = "SPELL Seal of Righteousness"
		ob["F4"] = "SPELL Seal of Insight"

		ob["NUMPADMINUS"] = "SPELL Avenging Wrath"
		ob["NUMPADPLUS"]  = "SPELL Holy Avenger"

		ob["NUMPADDECIMAL"] = "SPELL Ardent Defender"
		ob["NUMPAD0"] = "SPELL Guardian of Ancient Kings"
		ob["NUMPAD3"] = "SPELL Divine Protection"
		ob["NUMPAD2"] = "SPELL Divine Shield"
		ob["NUMPAD6"] = "SPELL Devotion Aura"
]]
	elseif c == "WARLOCK" then
		ob["T"] = "PETATTACK"
		ob["G"] = "MACRO Teleport"
		ob["W"] = "MACRO Soulshatter"
		ob["NUMPADPLUS"] = "MACRO Power"
--[[
					  O		Unending Breath
		              P		Eye of Kilrogg

			          V		Enslave Demon
			          X		Fear
		              Z		Banish

			    SHIFT-T		Demonic Circle: Teleport
			ALT-SHIFT-T		Demonic Circle: Summon

			          W		Soulshatter
			         F4		Ember Tap
			         F5		Flames of Xoroth
		        NUMPAD0		Unending Resolve
		  NUMPADDECIMAL		Twilight Ward

		              Q		Havoc
		     NUMPADPLUS		Dark Soul: Instability
		CTRL+NUMPADPLUS		Dark Intent
		 NUMPADMULTIPLY		Summon Abyssal
		   NUMPADDIVIDE		Summon Terrorguard
--]]
	end

	for key, action in pairs(ob) do
		SetOverrideBinding(PhanxBindFrame, nil, key, action)
	end

	if not silent then
		print("Override bindings applied.")
	end
end

function ApplyDefaultActionBindings(full, silent)
	SetBinding("1", "ACTIONBUTTON1")
	SetBinding("2", "ACTIONBUTTON2")
	SetBinding("3", "ACTIONBUTTON3")
	SetBinding("4", "ACTIONBUTTON4")
	SetBinding("5", "ACTIONBUTTON5")
	SetBinding("6", "ACTIONBUTTON6")

	if not full then
		if not silent then
			print("Bindings applied for action buttons 1-6.")
		end
		return
	end

	SetBinding("7", "ACTIONBUTTON7")
	SetBinding("8", "ACTIONBUTTON8")
	SetBinding("9", "ACTIONBUTTON9")
	SetBinding("0", "ACTIONBUTTON10")
	SetBinding("-", "ACTIONBUTTON11")
	SetBinding("=", "ACTIONBUTTON12")

	if not silent then
		print("Bindings applied for action buttons 1-12.")
	end
end

SetBinding("ESCAPE", "TOGGLEGAMEMENU")
SetBinding("/", "OPENCHATSLASH")

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
	ApplyMyBindings(true)
	ApplyMyOverrideBindings(true)
	ApplyDefaultActionBindings(nil, true)
end)