--Shares settings table
LydsPlayer.Settings = LydsPlayer.Settings or {}

--function to register client settings
function LydsPlayer.RegisterClientSettings(client)
	LydsPlayer.RegisterSettings({}, client)
end

--returns true if we have saved settings or not depending on environment (client or server)
function LydsPlayer.HasSavedSettings()

	local f = "lyds/settings.json"

	if (CLIENT) then
		f = "lyds/settings_client.json"
	end

	return file.Exists(f,"DATA")
end

--function to register server settings
function LydsPlayer.RegisterServerSettings(server)
	LydsPlayer.RegisterSettings(server, {})
end

--returns true if setting exists
function LydsPlayer.HasSetting(k)
	return LydsPlayer.Settings[k] != nil
end

--this takes a table of settings and works out the type through the Value and then adds it using LydsPlayer.AddSetting, used in sh_settings.lua
function LydsPlayer.RegisterSettings(server, client)
	client = client or {}
	local fn = function(tab, key, is_server)
		if (tab.Value == nil ) then error("no value") end

		if (tab.Type == nil ) then

			local typ = type( tab.Value )

			if (typ == "table") then
				tab.Type = LydsPlayer.Type.TABLE
			elseif ( typ == "number") then
				tab.Type = LydsPlayer.Type.INT
			elseif ( typ == "boolean") then
				tab.Type = LydsPlayer.Type.BOOL
			else
				tab.Type = LydsPlayer.Type.STRING
			end
		end

		if (tab.Type == LydsPlayer.Type.INT and tab.Min == nil ) then
			tab.Min = 1
		end

		if (tab.Type == LydsPlayer.Type.INT and tab.Max == nil ) then
			tab.Max = 100
		end

		if (tab.Convar == nil ) then
			if (tab.Type != LydsPlayer.Type.TABLE ) then
				tab.Convar = true
			else
				tab.Convar = false
			end
		end

		if (tab.Type == LydsPlayer.Type.BOOL ) then
			if (tab.Value == true) then
				tab.Value = 1
			else
				tab.Value = 0
			end
		end

		tab.Server = is_server

		if (tab.Refresh == nil) then
			tab.Refresh = true
		end

		tab.Key = key

		LydsPlayer.AddSetting(tab)
	end


	for k,t in pairs( server ) do
		fn(t, k, true )
	end

	for k,t in pairs( client ) do
		fn(t, k, false)
	end
end

--Takes a table and adds it to the global settings table if it doesn't already exist, it also creates various convars if it needs too
function LydsPlayer.AddSetting(tab)
	if (!table.HasValue(LydsPlayer.Type,tab.Type)) then return end
	if (LydsPlayer.Settings[tab.key]) then return end

	if (tab.Convar and tab.Type != LydsPlayer.Type.TABLE) then
		if (!tab.Server and CLIENT ) then
			if (!ConVarExists(tab.Key)) then
				print("creating client side convar: " .. tab.Key)
				CreateClientConVar(tab.Key,tab.Value)
			else
				print("already existing client side convar: " .. tab.Key)
			end
		elseif (tab.Server and SERVER) then
			if (!ConVarExists(tab.Key)) then
				print("creating server side convar: " .. tab.Key)
				CreateConVar(tab.Key,tab.Value)
			else
				print("already existing server side convar: " .. tab.Key)
			end
		end
	end

	if (tab.Server and CLIENT ) then return end
	if (!tab.Server and SERVER ) then return end

	LydsPlayer.Settings[tab.Key] = {}
	if (!LydsPlayer.Settings[tab.Key][tab.Type]) then LydsPlayer.Settings[tab.Key][tab.Type] = {} end

	if (tab.Type == LydsPlayer.Type.INT) then
		tab.Value = math.Truncate(tab.Value)
	end

	if (tab.Type  == LydsPlayer.Type.BOOL) then
		tab.Value = ( tab.Value == 1 or tab.Value == true )
	end

	if (tab.Type == LydsPlayer.Type.TABLE ) then
		tab.DefValue = table.Copy(tab.Value)
	elseif (tab.Type == LydsPlayer.Type.STRING ) then
		tab.DefValue = "" .. tab.Value
	elseif ( tab.Type == LydsPlayer.Type.BOOL ) then
		tab.DefValue = tab.Value
	else
		tab.DefValue = 0 + tab.Value
	end

	if (tab.Comment == nil ) then
		tab.Comment = "(unimplemented)"
	end

	if (tab.SlowUpdate == nil ) then
		tab.SlowUpdate = false
	end

	LydsPlayer.Settings[tab.Key][tab.Type] = {
		Value = tab.Value,
		DefValue = tab.DefValue or {},
		Type = tab.Type,
		Key = tab.Key,
		Max = tab.Max,
		Min = tab.Min,
		Icon = tab.Icon,
		Custom = tab.Custom,
		Server = tab.Server,
		Convar = tab.Convar,
		Comment = tab.Comment,
		Refresh = tab.Refresh or false,
		SlowUpdate = tab.SlowUpdate,
		Dangerous = tab.Dangerous or false
	}
end

--changes a setting to another value, will copy tables given.
function LydsPlayer.ChangeSetting(key, value, all_kinds)
	all_kinds = all_kinds or true
	for k,keys in pairs(LydsPlayer.Settings) do
		if (k != key) then
			continue
		end

		for kind,v in pairs(keys) do
			if (kind == LydsPlayer.Type.BOOL) then
				value = ( value == 1 or value == true )
			end

			if (kind == LydsPlayer.Type.INT) then
				value = math.Truncate(value)
			end

			if (kind == LydsPlayer.Type.TABLE) then
				LydsPlayer.Settings[key][kind].Value = table.Copy(value)
			else
				LydsPlayer.Settings[key][kind].Value = value

				if (ConVarExists(key)) then
					local convar = GetConVar(key)

					if (kind == LydsPlayer.Type.INT) then
						convar:SetInt(math.floor(value))
					elseif (kind == LydsPlayer.Type.BOOL) then
						convar:SetBool(value)
					elseif (kind == LydsPlayer.Type.STRING ) then
						convar:SetString(value)
					end

					if (!all_kinds) then
						return
					end
				end
			end

			--only once we'vefound
			return
		end
	end
end

--returns true if the setting is true
function LydsPlayer.IsSettingTrue(key)
	return LydsPlayer.GetSetting(key, true ).Value == true
end

function LydsPlayer.GetSettingInt(key)

	return LydsPlayer.GetSetting(key, true ).Value
end

LydsPlayer.SettingTrue = LydsPlayer.IsSettingTrue

--Gets a setting, second argument assures its type to be correct (1 to True, truncate ints)
function LydsPlayer.GetSetting(key, assure_type)
	assure_type = assure_type or false
	if (table.IsEmpty(LydsPlayer.Settings)) then errorBad("SETTINGS EMPTY") end

	for k,keys in pairs(LydsPlayer.Settings) do
		if (k == key ) then
			for kind,v in pairs(keys) do
				if (assure_type and kind == LydsPlayer.Type.BOOL) then
					v.Value = ( v.Value == 1 or v.Value == true )
				elseif (assure_type and kind == LydsPlayer.Type.INT) then
					v.Value = math.Truncate(v.Value)
				end

				return v
			end
		end
	end

	warning("setting not found: ", key)

	return {
		Value = nil,
		DefValue = nil,
		Type = nil,
		Icon = nil
	}
end

--Resets settings to their default values on either the server or the client
function LydsPlayer.ResetSettings()
	for k,keys in pairs(LydsPlayer.Settings) do
		for kind,v in pairs(keys) do
			if (v.Server and CLIENT ) then continue end --skip server if we are client
			if (!v.Server and SERVER ) then continue end --skip client if we are server

			if (ConVarExists(k) and v.Convar) then
				local convar = GetConVar(k)
				if ( kind == LydsPlayer.Type.INT) then
					convar:SetInt(v.DefValue)
				elseif (kind == LydsPlayer.Type.STRING) then
					convar:SetString(v.DefValue)
				elseif ( kind == LydsPlayer.Type.BOOL) then
					convar:SetBool(v.DefValue)
				end

				if (SERVER) then
					print("reset server convar " .. k .. " to ", v.Value )
				else
					print("reset client convar " .. k .. " to ", v.Value )
				end
			end

			if (kind == LydsPlayer.Type.BOOL) then
				LydsPlayer.Settings[k][kind].Value = ( v.DefValue == 1 or v.DefValue == true )
			elseif (kind == LydsPlayer.Type.TABLE ) then
				LydsPlayer.Settings[k][kind].Value = table.Copy(v.DefValue)
			else
				LydsPlayer.Settings[k][kind].Value = v.DefValue
			end
		end
	end
end

function LydsPlayer.ResetSetting(key)
	for k,keys in pairs(LydsPlayer.Settings) do
		if (k != key) then continue end

		for kind,v in pairs(keys) do
			if (kind == LydsPlayer.Type.BOOL) then
				LydsPlayer.Settings[k][kind].Value = ( v.DefValue == 1 or v.DefValue == true )
			elseif (kind == LydsPlayer.Type.TABLE ) then
				LydsPlayer.Settings[k][kind].Value = table.Copy(v.DefValue)
			else
				LydsPlayer.Settings[k][kind].Value = v.DefValue
			end
		end
	end
end

--this is named differently if we are playing locally
if (SERVER) then
	--server only
	concommand.Add("media_reset_settings", function(ply, cmd, args )
		if (!ply:IsAdmin()) then return end

		LydsPlayer.ResetSettings()
	end)
end

if (CLIENT) then
	--client only
	concommand.Add("media_reset_cl_settings", function(ply, cmd, args )

		LydsPlayer.ResetSettings()
		--recreate UI
		RunConsoleCommand("media_create_cl")
	end)
end

--takes the convar values and set settings to their value
function LydsPlayer.ResyncConvars()
	for k,keys in pairs(LydsPlayer.Settings) do
		for kind,v in pairs(keys) do
			if (v.Server and CLIENT) then continue end
			if (!v.Server and SERVER) then continue end

			if (!v.Convar ) then continue end --since some settings might not have associated convar values
			if (!ConVarExists(k)) then continue end

			local convar = GetConVar(k)
			local value = 0

			if (kind == LydsPlayer.Type.INT) then
				value = convar:GetInt()
			elseif (kind == LydsPlayer.Type.STRING ) then
				value = convar:GetString()
			elseif (kind == LydsPlayer.Type.BOOL ) then
				value = convar:GetBool()
			end

			v.Value = value
			LydsPlayer.Settings[k][kind] = v

			print("set convar " .. k .. " to ", v.Value )
		end
	end
end

--Sets the convars from the settings
function LydsPlayer.SetConvars()
	for k,keys in pairs(LydsPlayer.Settings) do
		for kind,v in pairs(keys) do
			if (v.Server and CLIENT) then continue end
			if (!v.Server and SERVER) then continue end

			if (!v.Convar ) then continue end --since some settings might not have associated convar values
			if (!ConVarExists(k)) then continue end

			local convar = GetConVar(k)
			if (kind == LydsPlayer.Type.INT) then
				convar:SetInt(v.Value)
			elseif (kind == LydsPlayer.Type.STRING) then
				convar:SetString(v.Value)
			elseif (kind == LydsPlayer.Type.BOOL) then
				convar:SetBool(v.Value)
			else
				convar:SetInt(v.Value)
			end

			print("set convar " .. k .. " to ", v.Value )
		end
	end
end

--this is named differently if we are playing locally
if (SERVER) then
	--server only
	concommand.Add("media_resync_convars", function(ply, cmd, args )
		LydsPlayer.ResyncConvars()

		if (!ply:IsAdmin()) then
			ply:SendMediaPlayerAdminSettings()
			return
		end
	end)
end

if (CLIENT) then
	--client only
	concommand.Add("media_cl_resync_convars", function(ply, cmd, args )
		LydsPlayer.ResyncConvars()
	end)
end

--loads our server settings
if (SERVER) then
	function LydsPlayer.LoadSettings()
		if (!file.IsDir("lyds", "DATA")) then return end
		if (!file.Exists("lyds/settings.json", "DATA")) then return end

		local settings = util.JSONToTable( file.Read("lyds/settings.json") )

		for k,keys in pairs(settings) do
			for kind,v in pairs(keys) do

				if (!LydsPlayer.Settings[k]) then continue end
				if (!LydsPlayer.Settings[k][kind]) then continue end

				local tab = LydsPlayer.Settings[k][kind]
				tab.Value = v.Value

				if (kind == LydsPlayer.Type.BOOL) then
					tab.Value = ( v.Value == 1 or v.Value == true )
				elseif (kind == LydsPlayer.Type.TABLE ) then
					for key,index in pairs(tab.DefValue) do
						tab.Value[key] = v.Value[key] or tab.DefValue[key]
					end
				else
					tab.Value = v.Value
				end

				LydsPlayer.Settings[k][kind] = tab
			end
		end
	end

	concommand.Add("media_load_settings", function()
		LydsPlayer.LoadSettings()
	end)
end

--loads our client settings
if (CLIENT) then
	function LydsPlayer.LoadSettings()
		if (!file.IsDir("lyds", "DATA")) then return end
		if (!file.Exists("lyds/settings_client.json", "DATA")) then return end
		local settings = util.JSONToTable( file.Read("lyds/settings_client.json") )

		for k,keys in pairs(settings) do
			for kind,v in pairs(keys) do
				if (!LydsPlayer.Settings[k]) then continue end
				if (!LydsPlayer.Settings[k][kind]) then continue end
				if (kind == LydsPlayer.Type.TABLE and LydsPlayer.Settings[k][kind].DefValue.__unpack) then
					for j,_k in pairs(v.Value) do
						v.Value[j] = LydsPlayer.Settings[k][kind].DefValue.__unpack(LydsPlayer.Settings[k][kind], j, _k)
					end
				end

				local tab = LydsPlayer.Settings[k][kind]

				if (kind == LydsPlayer.Type.BOOL) then
					tab.Value = ( v.Value == 1 or v.Value == true )
				elseif (kind == LydsPlayer.Type.TABLE ) then
					for key,index in pairs(tab.DefValue) do
						tab.Value[key] = v.Value[key] or tab.DefValue[key]
					end
				else
					tab.Value = v.Value
				end

				LydsPlayer.Settings[k][kind] = tab
			end
		end
	end

	concommand.Add("media_cl_load_settings", function()
		LydsPlayer.LoadSettings()
	end)
end

--saves our server settings
if (SERVER) then
	function LydsPlayer.SaveSettings()
		if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end
		local values = {}

		for k,keys in pairs(LydsPlayer.Settings) do
			for kind,v in pairs(keys) do

				if (!v.Server and SERVER) then continue end
				if (!values[k]) then values[k] = {} end


				if (kind == LydsPlayer.Type.INT ) then
					v.Value = math.Truncate(v.Value)
				end

				values[k][kind] = {
					Value = v.Value
				}
			end
		end

		file.Write("lyds/settings.json", util.TableToJSON( values ))
	end

	concommand.Add( "media_save_settings", function()
		LydsPlayer.SaveSettings()
	end)
end

--saves our client settings
if (CLIENT) then
	function LydsPlayer.SaveSettings()
		if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

		local values = {}

		for k,keys in pairs(LydsPlayer.Settings) do
			for kind,v in pairs(keys) do
				if (v.Server and CLIENT) then continue end

				if (!values[k]) then values[k] = {} end

				if ( kind == LydsPlayer.Type.TABLE and LydsPlayer.Settings[k][kind].DefValue.__pack) then
					for j,_k in pairs(v.Value) do
						v.Value[j] = LydsPlayer.Settings[k][kind].DefValue.__pack(LydsPlayer.Settings[k][kind], j, _k)
					end
				end

				if (kind == LydsPlayer.Type.INT ) then
					v.Value = math.Truncate(v.Value)
				end

				values[k][kind] = {
					Value = v.Value
				}
			end
		end

		file.Write("lyds/settings_client.json", util.TableToJSON( values ))
	end

	concommand.Add( "media_save_cl_settings", function()
		LydsPlayer.SaveSettings()
	end)
end

--only do this once
if (table.IsEmpty(LydsPlayer.Settings)) then
	hook.Run("LydsPlayer.SettingsLoaded") --hook onto this and then use RegisterSettings, see sh_settings.lua
end
