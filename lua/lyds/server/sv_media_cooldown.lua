--where all the active cooldowns are stored
LydsPlayer.Cooldown = LydsPlayer.Cooldown or {}

--Stored cooldowns which are used in the creation of new cooldowns
LydsPlayer.StoredCooldowns = LydsPlayer.StoredCooldowns or {}

--base cooldowns
LydsPlayer.BaseCooldown = {
	Name = "Default",
	Time = 5
}

--all of our default cooldowns
LydsPlayer.RegisteredCooldowns = LydsPlayer.RegisteredCooldowns or {
	Search = "cooldown_search",
	Play = "cooldown_play",
	Vote = "cooldown_vote",
	Interaction = "cooldown_interaction",
	History = "cooldown_history",
	Session = "cooldown_session",
	Command = "cooldown_command",
}

--loops through RegisteredCooldowns and creates new cooldowns based on their values, hook a function onto PreloadRegisteredCools and use LydsPlayer.AddRegisteredCooldowns
function LydsPlayer.LoadCooldowns()

	hook.Call("LydsPlayer.PreloadRegisteredCooldowns")

	for k,v in pairs(LydsPlayer.RegisteredCooldowns) do

		local setting =  LydsPlayer.GetSetting( v ) or {
			Value = 1
		}
		LydsPlayer.StoreCooldown( LydsPlayer.GetBaseCooldown(setting.Value, k ) )
	end

	--when we have loaded
	hook.Run("LydsPlayer.CooldownsLoaded")
end

--takes an array much like RegisteredCooldowns and adds it to the array
function LydsPlayer.AddRegisteredCooldowns(tab)

	for k,v in pairs(tab) do
		if (	LydsPlayer.RegisteredCooldowns[k] != nil) then error(k .. " already set") end
		LydsPlayer.RegisteredCooldowns[k] = v
	end
end

--stores a cooldown
function LydsPlayer.StoreCooldown(typ)
	if (LydsPlayer.StoredCooldowns[typ.Name]) then LydsPlayer.StoredCooldowns[typ.Name] = nil end

	LydsPlayer.StoredCooldowns[typ.Name] = typ
end

--gets a copy of a stored cooldown
function LydsPlayer.CopyCooldown(name)
	return table.Copy( LydsPlayer.StoredCooldowns[name] )
end

--returns true if cooldowns are disabled
function LydsPlayer.CooldownsAreDisabled()

	return !LydsPlayer.IsSettingTrue("cooldown_enabled")
end

--returns true if a player currently has that cooldown, takes Name of cooldown defined above
function LydsPlayer.HasCooldown(ply, name)
	if (LydsPlayer.CooldownsAreDisabled()) then return false end
	if (ply:IsAdmin() and LydsPlayer.IsSettingTrue("admin_ignore_cooldown")) then return false end
	if (LydsPlayer.Cooldown[ply:UniqueID()] == nil) then return false end

	return LydsPlayer.Cooldown[ply:UniqueID()][name] != nil
end

--returns true if we have a cooldown by checking the type of cooldown
function LydsPlayer.HasCooldownType(ply, typ)
	if (type(typ) != "table") then error("not a table") end
	if (!LydsPlayer.Cooldown[ply:UniqueID()]) then return false end

	return LydsPlayer.Cooldown[ply:UniqueID()][typ.Name] != nil
end

--copies the base cooldown
function LydsPlayer.GetBaseCooldown(time, name)
	if (!time) then time = LydsPlayer.BaseCooldown.Time end
	if (!name) then name = LydsPlayer.BaseCooldown.Default end

	local tab = table.Copy(LydsPlayer.BaseCooldown)
	tab.Time = time
	tab.Name = name

	return tab
end

--adds a cooldown for a player
function LydsPlayer.AddPlayerCooldown(ply, typ)
	if (LydsPlayer.CooldownsAreDisabled()) then return end
	if (ply:IsAdmin() and LydsPlayer.IsSettingTrue("admin_ignore_cooldown")) then return false end
	if (!LydsPlayer.Cooldown[ply:UniqueID()]) then LydsPlayer.Cooldown[ply:UniqueID()] = {} end
	if (LydsPlayer.Cooldown[ply:UniqueID()][typ.Name] ) then return end

	LydsPlayer.Cooldown[ply:UniqueID()][typ.Name] = typ
end

--updates all of the cooldowns deducting a second from their time
function LydsPlayer.UpdateCooldowns()
	for steamid,cooldowns in pairs(LydsPlayer.Cooldown) do
		for k,v in pairs(cooldowns) do
			if (!v.Time or v.Time < 1 ) then LydsPlayer.Cooldown[steamid][k] = nil end
			v.Time = v.Time - 1
		end

		if (table.IsEmpty(LydsPlayer.Cooldown[steamid])) then
			LydsPlayer.Cooldown[steamid] = nil
		end
	end
end

--called each interval updating all of the coolsdowns present in the system
function LydsPlayer.CooldownLoop()
	local setting = LydsPlayer.GetSetting("cooldown_refreshrate")

	--So we update our time
	timer.Create("LydsPlayer.CooldownLoop", setting.Value, 1, function()
		LydsPlayer.UpdateCooldowns()
		LydsPlayer.CooldownLoop()
	end)
end
