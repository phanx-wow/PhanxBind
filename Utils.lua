------------------------------------------------------------------------
--	This file provides the following global functions:
--
--	GetBindingFriendlyActionText(command)
--		Turns a binding command into a human-readable description of
--		the action to be performed when the binding is activated.
--		Accepts:
--			[1] command (string)
--		Returns:
--			[1] text (string)
--
--	DumpBindings(raw)
--		Lists all currently active bindings and their descriptions.
--		Accepts:
--			[1] raw (boolean)
--				Controls whether binding commands and descriptions
--				are converted into friendly texts or listed as-is.
--		Returns:
--			none
--
--	ClearAllBindings()
--		Removes all bindings, and then applies the following bindings:
--			[1] ESC -> Toggle main menu
--			[2] / -> Open chat input box with a pre-filled slash
------------------------------------------------------------------------

function GetBindingFriendlyActionText( command )
	local action, target = command:match( "^(%S+) ?(.*)$" )
	if action == "CLICK" then
		local button, click = target:match( "([^:]+):?(.*)" )
		return format( "Click with %s on %s", click or "LeftButton", button )
	elseif action == "ITEM" then
		return format( "Use item %s", target )
	elseif action == "MACRO" then
		return format( "Run macro %s", target )
	elseif action == "SPELL" then
		return format( "Cast spell %s", target )
	elseif action:sub( 1, 12 ) == "ACTIONBUTTON" then
		action = tonumber( action:match( "%d+" ) )
		local type, spell, subtype = GetActionInfo( action )
		if type == "companion" then
			spell = select( 2, GetCompanionInfo( "CRITTER", spell ) )
			return format( "Summon %s %s", subtype == "CRITTER" and "companion" or "mount", spell )
		elseif type == "equipmentset" then
			return format( "Equip set %s", spell )
		elseif type == "item" then
			spell = GetItemInfo( spell )
			return format( "Use item %s", spell )
		elseif type == "macro" then
			spell = GetMacroInfo( spell )
			return format( "Run macro %s", spell )
		elseif type == "spell" then
			spell = GetSpellInfo( spell )
			return format( "Cast spell %s", spell )
		else
			return GetBindingText( command, "BINDING_NAME_" )
		end
	elseif action:sub( 1, 18 ) == "BONUSACTIONBUTTON" then
		action = tonumber( action:match( "%d+" ) )
		local skill = GetPetActionInfo( action )
		if action then
			return format( "Use pet action %s", action )
		else
			return GetBindingText( command, "BINDING_NAME_" )
		end
	elseif action:sub( 1, 16 ) == "SHAPESHIFTBUTTON" then
		action = tonumber( action:match( "%d+" ) )
		local form = select( 2, GetShapeshiftFormInfo( action ) )
		if form then
			return format( "Change stance to %s", form )
		else
			return GetBindingText( command, "BINDING_NAME_" )
		end
	else
		return GetBindingText( command, "BINDING_NAME_" )
	end
end

function DumpBindings(raw)
	for i = 1, GetNumBindings() do
		local command = GetBinding( i )
		if command ~= "NONE" then
			for j = 2, select( "#", GetBinding( i ) ) do
				local key = select( j, GetBinding( i ) )
				if raw then
					print( key, "==>", command )
				else
					print( GetBindingText( key, "KEY_" ), "==>", GetBindingFriendlyActionText( command ) )
				end
			end
		end
	end
end

function ClearAllBindings()
	for i = 1, GetNumBindings() do
		for j = select( "#", GetBinding( i ) ), 2, -1 do
			local b = select( j, GetBinding( i ) )
			if b then
				SetBinding( b )
			end
		end
	end
	SetBinding( "ESCAPE", "TOGGLEGAMEMENU" )
	SetBinding( "/", "OPENCHATSLASH" )
end