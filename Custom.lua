function ApplyMyBindings(silent)
	ClearAllBindings()

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

	SetBinding("ENTER", "OPENCHAT")
	SetBinding("/", "OPENCHATSLASH")
	SetBinding("SHIFT-R", "REPLY")

	SetBinding("SHIFT-UP", "PREVIOUSACTIONPAGE")
	SetBinding("SHIFT-MOUSEWHEELUP", "PREVIOUSACTIONPAGE")
	SetBinding("SHIFT-DOWN", "NEXTACTIONPAGE")
	SetBinding("SHIFT-MOUSEWHEELDOWN", "NEXTACTIONPAGE")

	SetBinding("TAB", "TARGETNEARESTENEMY")
	SetBinding("SHIFT-TAB", "TARGETNEARESTFRIEND")

	SetBinding("SHIFT-V", "NAMEPLATES")
	SetBinding("CTRL-V", "FRIENDNAMEPLATES")

	SetBinding("T", "STARTATTACK")
	SetBinding("SHIFT-T", "ASSISTTARGET")
	SetBinding("ALT-T", "INTERACTTARGET")

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

	SetBinding("ALT-Z", "TOGGLEUI")
	SetBinding("CTRL-R", "TOGGLEFPS")
	SetBinding("PRINTSCREEN", "SCREENSHOT")

	SetBinding("MOUSEWHEELUP", "CAMERAZOOMIN")
	SetBinding("MOUSEWHEELDOWN", "CAMERAZOOMOUT")

	SetBinding("CTRL-MOUSEWHEELUP", "VEHICLEAIMUP")
	SetBinding("CTRL-MOUSEWHEELDOWN", "VEHICLEAIMDOWN")

	SetBinding("`", "CLICK Squire2Button:LeftButton")
	SetBinding("SHIFT-B", "BAGNON_BANK_TOGGLE")
	SetBinding("ALT-CTRL-F", "GOFISH_TOGGLE")
	SetBinding("ALT-SHIFT-F", "HYDRA_FOLLOW")
	SetBinding("CTRL-F", "HYDRA_FOLLOW_ME")
	SetBinding("I", "EXAMINER_TARGET")
	SetBinding("ALT-I", "EXAMINER_MOUSEOVER")
	SetBinding("ALT-SHIFT-L", "CLICK LevelFlightButton:LeftButton")
	SetBinding("ALT-CTRL-R", "RECOUNT_TOGGLE_MAIN")
	SetBinding("ALT-N", "NOTEBOOK_PANEL")
	SetBinding("ALT-X", "CLICK CancelMyBuffsButton1:LeftButton")

	if not silent then
		print("Bindings applied.")
	end
end

function ApplyMyOverrideBindings(silent)
	local _, c = UnitClass("player")
	local _, r = UnitRace("player")

	SetOverrideBinding(PhanxBindFrame, nil, "ALT-Q", "MACRO QuestItem")
	SetOverrideBinding(PhanxBindFrame, nil, "ALT-`", "ITEM Hearthstone")

	if r == "BloodElf" then
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADMINUS", "SPELL Arcane Torrent")
	elseif r == "Orc" then
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADMINUS", "SPELL Blood Fury")
	end

	if c == "DRUID" then
		SetOverrideBinding(PhanxBindFrame, nil, "F1", "MACRO Bear")
		SetOverrideBinding(PhanxBindFrame, nil, "F2", "MACRO Aquatic")
		SetOverrideBinding(PhanxBindFrame, nil, "F3", "MACRO Cat")
		SetOverrideBinding(PhanxBindFrame, nil, "F4", "MACRO Travel")
		SetOverrideBinding(PhanxBindFrame, nil, "F5", "MACRO Flight")
		SetOverrideBinding(PhanxBindFrame, nil, "C",  "MACRO Cure")
		SetOverrideBinding(PhanxBindFrame, nil, "G",  "MACRO Interrupt")
		SetOverrideBinding(PhanxBindFrame, nil, "Q",  "MACRO Q")
		SetOverrideBinding(PhanxBindFrame, nil, "W",  "MACRO Fire")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD0", "MACRO Power")

	elseif c == "MONK" then
		SetOverrideBinding(PhanxBindFrame, nil, "C",  "MACRO Cure")
		SetOverrideBinding(PhanxBindFrame, nil, "Q",  "SPELL Roll")

	elseif c == "SHAMAN" then
		SetOverrideBinding(PhanxBindFrame, nil, "C",  "MACRO Cure")
		SetOverrideBinding(PhanxBindFrame, nil, "G",  "SPELL Wind Shear")
		SetOverrideBinding(PhanxBindFrame, nil, "O",  "SPELL Far Sight")
		SetOverrideBinding(PhanxBindFrame, nil, "P",  "SPELL Water Walking")
		SetOverrideBinding(PhanxBindFrame, nil, "W",  "MACRO Shield")
		SetOverrideBinding(PhanxBindFrame, nil, "X",  "MACRO Hex")
		SetOverrideBinding(PhanxBindFrame, nil, "Z",  "MACRO Bind")
		SetOverrideBinding(PhanxBindFrame, nil, "ALT-`", "MACRO Home")
		SetOverrideBinding(PhanxBindFrame, nil, "CTRL-`", "SPELL Ghost Wolf")
		SetOverrideBinding(PhanxBindFrame, nil, "F1", "SPELL Earthbind Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "F2", "SPELL Searing Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "F3", "SPELL Healing Tide Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "F4", "SPELL Stormlash Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "F5", "SPELL Totemic Recall")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADDIVIDE", "SPELL Earth Elemental Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADMULTIPLY", "SPELL Fire Elemental Totem")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADPLUS", "SPELL Bloodlust")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADDECIMAL", "MACRO Defend")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD0", "MACRO Power")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD1", "SPELL Ascendance")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD2", "SPELL Spirit Walk")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD3", "SPELL Astral Shift")

	elseif c == "PALADIN" then
		SetOverrideBinding(PhanxBindFrame, nil, "G", 		"MACRO Interrupt")
		SetOverrideBinding(PhanxBindFrame, nil, "Q", 		"SPELL Reckoning")

		SetOverrideBinding(PhanxBindFrame, nil, "F1",	"SPELL Righteous Fury")
		SetOverrideBinding(PhanxBindFrame, nil, "F2",	"SPELL Seal of Truth")
		SetOverrideBinding(PhanxBindFrame, nil, "F3",	"SPELL Seal of Righteousness")
		SetOverrideBinding(PhanxBindFrame, nil, "F4",	"SPELL Seal of Insight")

		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADMINUS", 	 "SPELL Avenging Wrath")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADPLUS", 	 "SPELL Holy Avenger")

		SetOverrideBinding(PhanxBindFrame, nil, "NUMPADDECIMAL", "SPELL Ardent Defender")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD0", 		 "SPELL Guardian of Ancient Kings")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD3", 		 "SPELL Divine Protection")
		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD2", 		 "SPELL Divine Shield")

		SetOverrideBinding(PhanxBindFrame, nil, "NUMPAD6", 		 "SPELL Devotion Aura")

	elseif c == "WARLOCK" then
		SetOverrideBinding(PhanxBindFrame, nil, "T", "PETATTACK")
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

local f = CreateFrame("Frame", "PhanxBindFrame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
	ApplyMyBindings(true)
	ApplyMyOverrideBindings(true)
	ApplyDefaultActionBindings(nil, true)
end)