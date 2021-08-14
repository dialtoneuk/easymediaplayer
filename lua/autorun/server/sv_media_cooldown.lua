
--[[
	Holds our active cooldowns
--]]

MEDIA.Cooldown = MEDIA.Cooldown or {}

--Stored cooldowns for use later
MEDIA.StoredCooldowns = MEDIA.StoredCooldowns or {
	_CooldownType = {
		Name = "Default",
		Time = 5
	}
}

--[[
Cooldowns
Devs: You can add to this

Cooldowns are essentially rate limiters which only allow you to preform an action
ever so seconds in time.
---------------------------------------------------------------------------
--]]

function MEDIA.LoadCooldowns()
	--Search Cooldown
	local cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "Search"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_search").Value
	MEDIA.StoreCooldown(cooldown)

	--Play Cooldown
	cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "Play"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_play").Value
	MEDIA.StoreCooldown(cooldown)

	--Vote Cooldown
	cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "Vote"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_vote").Value
	MEDIA.StoreCooldown(cooldown)

	--Interaction Cooldown
	cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "Interaction"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_interaction").Value
	MEDIA.StoreCooldown(cooldown)

	--History Cooldown
	cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "History"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_history").Value
	MEDIA.StoreCooldown(cooldown)

	--Command Cooldown
	cooldown = MEDIA.GetCooldownType()
	cooldown.Name = "Command"
	cooldown.Time = MEDIA.GetSetting("media_cooldown_command").Value

	MEDIA.StoreCooldown(cooldown)
end

--[[
 Stores a copy of a cooldown for us to use
--]]

function MEDIA.StoreCooldown(typ)
	if (MEDIA.StoredCooldowns[typ.Name]) then MEDIA.StoredCooldowns[typ.Name] = nil end

	MEDIA.StoredCooldowns[typ.Name] = typ
end

--[[
Gets a new copy of a stored cooldown
--]]

function MEDIA.GetNewCooldown(name)
	return table.Copy( MEDIA.StoredCooldowns[name] )
end

function MEDIA.CooldownsAreDisabled()

	return MEDIA.GetSetting("media_cooldown_enabled").Value == false
end

--[[
	Return true if a player has a current cooldown
--]]

function MEDIA.HasCooldown(ply, name)
	if (MEDIA.CooldownsAreDisabled()) then return false end
	if (MEDIA.Cooldown[ply:UniqueID()] == nil) then return false end

	return MEDIA.Cooldown[ply:UniqueID()][name] != nil
end

--[[
	Return true if a player has dat current cooldown type
--]]

function MEDIA.HasCooldownType(ply, typ)
	if (!MEDIA.Cooldown[ply:UniqueID()]) then return false end

	return MEDIA.Cooldown[ply:UniqueID()][typ.Name] != nil
end

--[[
Gets a new cooldown type
--]]

function MEDIA.GetCooldownType(time, name)
		if (!time) then time = MEDIA.StoredCooldowns._CooldownType.Time end
		if (!name) then name = MEDIA.StoredCooldowns._CooldownType.Default end

		local tab = table.Copy(MEDIA.StoredCooldowns._CooldownType)
		tab.Time = time
		tab.Name = name

		return tab
end

--[[
	Adds a cooldown to the player, takes a Type name
--]]

function MEDIA.AddPlayerCooldown(ply, typ)
	if (MEDIA.CooldownsAreDisabled()) then return end
	if (!MEDIA.Cooldown[ply:UniqueID()]) then MEDIA.Cooldown[ply:UniqueID()] = {} end
	if (MEDIA.Cooldown[ply:UniqueID()][typ.Name] ) then return end

	MEDIA.Cooldown[ply:UniqueID()][typ.Name] = typ
end

--[[
	Loops through all the cooldowns and updates, this is called each time in MEDIA.CooldownLoop()
--]]

function MEDIA.UpdateCooldowns()
	for steamid,cooldowns in pairs(MEDIA.Cooldown) do
		for k,v in pairs(cooldowns) do
			if (!v.Time or v.Time < 1 ) then MEDIA.Cooldown[steamid][k] = nil end
			v.Time = v.Time - 1
		end

		if (table.IsEmpty(MEDIA.Cooldown[steamid])) then
			MEDIA.Cooldown[steamid] = nil
		end
	end
end

--[[
	Once initiated, will be called each second updating all current cooldowns present.
	The refreshrate can be halved to make it go faster
--]]

function MEDIA.CooldownLoop()
	local setting = MEDIA.GetSetting("media_cooldown_refreshrate") or {Value = 1}

	--So we update our time
	timer.Create("MEDIA.CooldownLoop", setting.Value, 1, function()
		MEDIA.UpdateCooldowns()
		MEDIA.CooldownLoop()
	end)
end

--when we have loaded this file
hook.Run("MEDIA.CooldownLoaded")
