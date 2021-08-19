
--[[
	Holds our active cooldowns
--]]

MediaPlayer.Cooldown = MediaPlayer.Cooldown or {}

--Stored cooldowns for use later
MediaPlayer.StoredCooldowns = MediaPlayer.StoredCooldowns or {
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

function MediaPlayer.LoadCooldowns()
	--Search Cooldown
	local cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "Search"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_search").Value
	MediaPlayer.StoreCooldown(cooldown)

	--Play Cooldown
	cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "Play"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_play").Value
	MediaPlayer.StoreCooldown(cooldown)

	--Vote Cooldown
	cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "Vote"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_vote").Value
	MediaPlayer.StoreCooldown(cooldown)

	--Interaction Cooldown
	cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "Interaction"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_interaction").Value
	MediaPlayer.StoreCooldown(cooldown)

	--History Cooldown
	cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "History"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_history").Value
	MediaPlayer.StoreCooldown(cooldown)

	--Command Cooldown
	cooldown = MediaPlayer.GetCooldownType()
	cooldown.Name = "Command"
	cooldown.Time = MediaPlayer.GetSetting("MediaPlayer_cooldown_command").Value

	MediaPlayer.StoreCooldown(cooldown)

	--when we have loaded this file
	hook.Run("MediaPlayer.PreloadRegisteredCooldowns")
end

--[[
 Stores a copy of a cooldown for us to use
--]]

function MediaPlayer.StoreCooldown(typ)
	if (MediaPlayer.StoredCooldowns[typ.Name]) then MediaPlayer.StoredCooldowns[typ.Name] = nil end

	MediaPlayer.StoredCooldowns[typ.Name] = typ
end

--[[
Gets a new copy of a stored cooldown
--]]

function MediaPlayer.GetNewCooldown(name)
	return table.Copy( MediaPlayer.StoredCooldowns[name] )
end

function MediaPlayer.CooldownsAreDisabled()

	return !MediaPlayer.IsSettingTrue("MediaPlayer_cooldown_enabled")
end

--[[
	Return true if a player has a current cooldown
--]]

function MediaPlayer.HasCooldown(ply, name)
	if (MediaPlayer.CooldownsAreDisabled()) then return false end
	if (MediaPlayer.Cooldown[ply:UniqueID()] == nil) then return false end

	return MediaPlayer.Cooldown[ply:UniqueID()][name] != nil
end

--[[
	Return true if a player has dat current cooldown type
--]]

function MediaPlayer.HasCooldownType(ply, typ)
	if (!MediaPlayer.Cooldown[ply:UniqueID()]) then return false end

	return MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] != nil
end

--[[
Gets a new cooldown type
--]]

function MediaPlayer.GetCooldownType(time, name)
		if (!time) then time = MediaPlayer.StoredCooldowns._CooldownType.Time end
		if (!name) then name = MediaPlayer.StoredCooldowns._CooldownType.Default end

		local tab = table.Copy(MediaPlayer.StoredCooldowns._CooldownType)
		tab.Time = time
		tab.Name = name

		return tab
end

--[[
	Adds a cooldown to the player, takes a Type name
--]]

function MediaPlayer.AddPlayerCooldown(ply, typ)
	if (MediaPlayer.CooldownsAreDisabled()) then return end
	if (!MediaPlayer.Cooldown[ply:UniqueID()]) then MediaPlayer.Cooldown[ply:UniqueID()] = {} end
	if (MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] ) then return end

	MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] = typ
end

--[[
	Loops through all the cooldowns and updates, this is called each time in MediaPlayer.CooldownLoop()
--]]

function MediaPlayer.UpdateCooldowns()
	for steamid,cooldowns in pairs(MediaPlayer.Cooldown) do
		for k,v in pairs(cooldowns) do
			if (!v.Time or v.Time < 1 ) then MediaPlayer.Cooldown[steamid][k] = nil end
			v.Time = v.Time - 1
		end

		if (table.IsEmpty(MediaPlayer.Cooldown[steamid])) then
			MediaPlayer.Cooldown[steamid] = nil
		end
	end
end

--[[
	Once initiated, will be called each second updating all current cooldowns present.
	The refreshrate can be halved to make it go faster
--]]

function MediaPlayer.CooldownLoop()
	local setting = MediaPlayer.GetSetting("MediaPlayer_cooldown_refreshrate")

	--So we update our time
	timer.Create("MediaPlayer.CooldownLoop", setting.Value, 1, function()
		MediaPlayer.UpdateCooldowns()
		MediaPlayer.CooldownLoop()
	end)
end

--when we have loaded this file
hook.Run("MediaPlayer.CooldownLoaded")
