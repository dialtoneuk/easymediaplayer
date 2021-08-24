--where all the active cooldowns are stored
MediaPlayer.Cooldown = MediaPlayer.Cooldown or {}

--Stored cooldowns which are used in the creation of new cooldowns
MediaPlayer.StoredCooldowns = MediaPlayer.StoredCooldowns or {}

--base cooldowns
MediaPlayer.BaseCooldown = {
	Name = "Default",
	Time = 5
}

--all of our default cooldowns
MediaPlayer.RegisteredCooldowns = MediaPlayer.RegisteredCooldowns or {
	Search = "media_cooldown_search",
	Play = "media_cooldown_play",
	Vote = "media_cooldown_vote",
	Interaction = "media_cooldown_interaction",
	History = "media_cooldown_history",
	Command = "media_cooldown_command",
}

--loops through RegisteredCooldowns and creates new cooldowns based on their values, hook a function onto PreloadRegisteredCools and use MediaPlayer.AddRegisteredCooldowns
function MediaPlayer.LoadCooldowns()

	hook.Call("MediaPlayer.PreloadRegisteredCooldowns")

	for k,v in pairs(MediaPlayer.RegisteredCooldowns) do

		local setting =  MediaPlayer.GetSetting( v ) or {
			Value = 1
		}
		MediaPlayer.StoreCooldown( MediaPlayer.GetBaseCooldown(setting.Value, k ) )
	end

	--when we have loaded
	hook.Run("MediaPlayer.CooldownsLoaded")
end

--takes an array much like RegisteredCooldowns and adds it to the array
function MediaPlayer.AddRegisteredCooldowns(tab)

	for k,v in pairs(tab) do
		if (	MediaPlayer.RegisteredCooldowns[k] != nil) then error(k .. " already set") end
		MediaPlayer.RegisteredCooldowns[k] = v
	end
end

--stores a cooldown
function MediaPlayer.StoreCooldown(typ)
	if (MediaPlayer.StoredCooldowns[typ.Name]) then MediaPlayer.StoredCooldowns[typ.Name] = nil end

	MediaPlayer.StoredCooldowns[typ.Name] = typ
end

--gets a copy of a stored cooldown
function MediaPlayer.CopyCooldown(name)
	return table.Copy( MediaPlayer.StoredCooldowns[name] )
end

--returns true if cooldowns are disabled
function MediaPlayer.CooldownsAreDisabled()

	return !MediaPlayer.IsSettingTrue("media_cooldown_enabled")
end

--returns true if a player currently has that cooldown, takes Name of cooldown defined above
function MediaPlayer.HasCooldown(ply, name)
	if (MediaPlayer.CooldownsAreDisabled()) then return false end
	if (MediaPlayer.Cooldown[ply:UniqueID()] == nil) then return false end

	return MediaPlayer.Cooldown[ply:UniqueID()][name] != nil
end

--returns true if we have a cooldown by checking the type of cooldown
function MediaPlayer.HasCooldownType(ply, typ)
	if (type(typ) != "table") then error("not a table") end
	if (!MediaPlayer.Cooldown[ply:UniqueID()]) then return false end

	return MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] != nil
end

--copies the base cooldown
function MediaPlayer.GetBaseCooldown(time, name)
	if (!time) then time = MediaPlayer.BaseCooldown.Time end
	if (!name) then name = MediaPlayer.BaseCooldown.Default end

	local tab = table.Copy(MediaPlayer.BaseCooldown)
	tab.Time = time
	tab.Name = name

	return tab
end

--adds a cooldown for a player
function MediaPlayer.AddPlayerCooldown(ply, typ)
	if (MediaPlayer.CooldownsAreDisabled()) then return end
	if (!MediaPlayer.Cooldown[ply:UniqueID()]) then MediaPlayer.Cooldown[ply:UniqueID()] = {} end
	if (MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] ) then return end

	MediaPlayer.Cooldown[ply:UniqueID()][typ.Name] = typ
end

--updates all of the cooldowns deducting a second from their time
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

--called each interval updating all of the coolsdowns present in the system
function MediaPlayer.CooldownLoop()
	local setting = MediaPlayer.GetSetting("media_cooldown_refreshrate")

	--So we update our time
	timer.Create("MediaPlayer.CooldownLoop", setting.Value, 1, function()
		MediaPlayer.UpdateCooldowns()
		MediaPlayer.CooldownLoop()
	end)
end
