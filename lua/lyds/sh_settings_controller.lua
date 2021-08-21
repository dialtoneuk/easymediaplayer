--[[
	Super cool settings system that allows for tables, ints and strings to be saved to the /data/ folder on both the client
	and server's end, all editable via an easy to use panel.

	Each setting also has a server convar value attached to it, Server and client convars are synced so use them like you would normally and everything should work fine. The
	settings will be replaced by the convars. The system will create all convars that do not exist with their current settings values.

	Written by Llydia Cross 2020.
--]]

--Our settings
MediaPlayer.Settings = MediaPlayer.Settings or {}

--[[
	Registers an array of client settings
--]]
function MediaPlayer.RegisterClientSettings(client)
	MediaPlayer.RegisterSettings({}, client)
end

function MediaPlayer.HasSavedSettings()

	local f = "lyds/settings.json"

	if (CLIENT) then
		f = "lyds/settings_client.json"
	end

	return file.Exists(f,"DATA")
end
--[[
	Registers an array of server settings
--]]

function MediaPlayer.RegisterServerSettings(server)
	MediaPlayer.RegisterSettings(server, {})
end

--[[
	Registers both server and client settings
--]]

function MediaPlayer.RegisterSettings(server, client)
	local fn = function(tab, key, is_server)
		if (tab.Value == nil ) then error("no value") end

		if (tab.Type == nil ) then

			local typ = type( tab.Value )

			if (typ == "table") then
				tab.Type = MediaPlayer.Type.TABLE
			elseif ( typ == "number") then
				tab.Type = MediaPlayer.Type.INT
			elseif ( typ == "boolean") then
				tab.Type = MediaPlayer.Type.BOOL
			else
				tab.Type = MediaPlayer.Type.STRING
			end
		end

		if (tab.Type == MediaPlayer.Type.INT and tab.Min == nil ) then
			tab.Min = 1
		end

		if (tab.Type == MediaPlayer.Type.INT and tab.Max == nil ) then
			tab.Max = 100
		end

		if (tab.Convar == nil ) then
			if (tab.Type != MediaPlayer.Type.TABLE ) then
				tab.Convar = true
			else
				tab.Convar = false
			end
		end

		if (tab.Type == MediaPlayer.Type.BOOL ) then
			if (tab.Value == true) then
				tab.Value = 1
			else
				tab.Value = 0
			end
		end

		tab.Server = is_server

		if (tab.Server == false and tab.Refresh == nil and tab.Type != MediaPlayer.Type.TABLE ) then
			tab.Refresh = true
		end

		tab.Key = key

		MediaPlayer.AddSetting(tab)
	end


	for k,t in pairs( server ) do
		fn(t, k, true )
	end

	for k,t in pairs( client ) do
		fn(t, k, false)
	end
end

--[[
Add Setting
--]]

function MediaPlayer.AddSetting(tab)
	if (!table.HasValue(MediaPlayer.Type,tab.Type)) then return end
	if (MediaPlayer.Settings[tab.key]) then return end

	if (tab.Convar and tab.Type != MediaPlayer.Type.TABLE) then
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

	MediaPlayer.Settings[tab.Key] = {}
	if (!MediaPlayer.Settings[tab.Key][tab.Type]) then MediaPlayer.Settings[tab.Key][tab.Type] = {} end

	if (tab.Type == MediaPlayer.Type.INT) then
		tab.Value = math.Truncate(tab.Value)
	end

	if (tab.Type  == MediaPlayer.Types.BOOL) then
		tab.Value = ( tab.Value == 1 or tab.Value == true )
	end

	if (tab.Type == MediaPlayer.Types.TABLE ) then
		tab.DefValue = table.Copy(tab.Value)
	elseif (tab.Type == MediaPlayer.Types.STRING ) then
		tab.DefValue = "" .. tab.Value
	elseif ( tab.Type == MediaPlayer.Types.BOOL ) then
		tab.DefValue = tab.Value
	else
		tab.DefValue = 0 + tab.Value
	end

	MediaPlayer.Settings[tab.Key][tab.Type] = {
		Value = tab.Value,
		DefValue = tab.DefValue or {},
		Type = tab.Type,
		Key = tab.Key,
		Max = tab.Max or 6400,
		Min = tab.Min or 0,
		Custom = tab.Custom or false,
		Server = tab.Server or false,
		Convar = tab.Convar or false,
		Comment = tab.Comment or false,
		Refresh = tab.Refresh or false,
		SlowUpdate = tab.SlowUpdate or false
	}
end

--[[
chnanges the value of a setting
]]--

function MediaPlayer.ChangeSetting(key, value, all_kinds)
	all_kinds = all_kinds or true
	for k,keys in pairs(MediaPlayer.Settings) do
		if (k != key) then
			continue
		end

		for kind,v in pairs(keys) do
			if (kind == MediaPlayer.Types.BOOL) then
				value = ( value == 1 or value == true )
			end

			if (kind == MediaPlayer.Type.INT) then
				value = math.Truncate(value)
			end

			if (kind == MediaPlayer.Type.TABLE) then
				MediaPlayer.Settings[key][kind].Value = table.Copy(value)
			else
				MediaPlayer.Settings[key][kind].Value = value

				if (ConVarExists(key)) then
					local convar = GetConVar(key)

					if (kind == MediaPlayer.Type.INT) then
						convar:SetInt(math.floor(value))
					elseif (kind == MediaPlayer.Type.BOOL) then
						convar:SetBool(value)
					elseif (kind == MediaPlayer.Type.STRING ) then
						convar:SetString(value)
					end

					print("set convar " .. k .. " to ", value)

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

--
function MediaPlayer.IsSettingTrue(key)
	return MediaPlayer.GetSetting(key, true ).Value == true
end

function MediaPlayer.SettingTrue(key)
	warning("DEPRACATED! call to settings true")
	return MediaPlayer.SettingTrue(key)
end

--[[
Gets a setting
--]]

function MediaPlayer.GetSetting(key, assure_type)
	assure_type = assure_type or false
	if (table.IsEmpty(MediaPlayer.Settings)) then errorBad("SETTINGS EMPTY") end

	for k,keys in pairs(MediaPlayer.Settings) do
		if (k == key ) then
			for kind,v in pairs(keys) do
				if (assure_type and kind == MediaPlayer.Types.BOOL) then
					v.Value = ( v.Value == 1 or v.Value == true )
				end

				return v
			end
		end
	end

	warning("setting not found: ", key)

	return {
		Value = nil,
		DefValue = nil,
		Type = nil
	}
end

--[[
Resets our convars, works on client too
--]]

if ( SERVER ) then
	function MediaPlayer.ResetSettings()
		for k,keys in pairs(MediaPlayer.Settings) do
			for kind,v in pairs(keys) do
				if (!v.Server and SERVER ) then continue end

				if (ConVarExists(k) and v.Convar) then
					local convar = GetConVar(k)
					if ( kind == MediaPlayer.Type.INT) then
						convar:SetInt(v.DefValue)
					elseif (kind == MediaPlayer.Type.STRING) then
						convar:SetString(v.DefValue)
					elseif ( kind == MediaPlayer.Type.BOOL) then
						convar:SetBool(v.DefValue)
					end

					print("reset server convar " .. k .. " to ", v.Value )
				end

				if (kind == MediaPlayer.Types.BOOL) then
					MediaPlayer.Settings[k][kind].Value = ( v.DefValue == 1 or v.DefValue == true )
				elseif (kind == MediaPlayer.Types.TABLE ) then
					MediaPlayer.Settings[k][kind].Value = table.Copy(v.DefValue)
				else
					MediaPlayer.Settings[k][kind].Value = v.DefValue
				end
			end
		end
	end
end


--[[
Resets our settings CL
--]]

if ( CLIENT ) then
	function MediaPlayer.ResetSettings()
		for k,keys in pairs(MediaPlayer.Settings) do
			for kind,v in pairs(keys) do
				if (v.Server and CLIENT ) then continue end

				if (ConVarExists(k) and v.Convar) then
					local convar = GetConVar(k)
					if ( kind == MediaPlayer.Type.INT) then
						convar:SetInt(v.DefValue)
					elseif (kind == MediaPlayer.Type.STRING) then
						convar:SetString(v.DefValue)
					elseif ( kind == MediaPlayer.Type.BOOL) then
						convar:SetBool(v.DefValue)
					end
				end

				if (kind == MediaPlayer.Types.BOOL) then
					MediaPlayer.Settings[k][kind].Value = ( v.DefValue == 1 or v.DefValue == true )
				elseif (kind == MediaPlayer.Types.TABLE ) then
					MediaPlayer.Settings[k][kind].Value = table.Copy(v.DefValue)
				else
					MediaPlayer.Settings[k][kind].Value = (0 + v.DefValue)
				end
			end
		end
	end
end

--this is named differently if we are playing locally

if (SERVER) then
	--server only
	concommand.Add("media_reset_settings", function(ply, cmd, args )
		if (!ply:IsAdmin()) then return end

		MediaPlayer.ResetSettings()
	end)
end

if (CLIENT) then
	--client only
	concommand.Add("media_reset_cl_settings", function(ply, cmd, args )

		MediaPlayer.ResetSettings()
		--recreate UI
		RunConsoleCommand("media_create_cl")
	end)
end

--[[
	Syncs our settings with our convars and vice versa
--]]

function MediaPlayer.ResyncConvars()
	for k,keys in pairs(MediaPlayer.Settings) do
		for kind,v in pairs(keys) do
			if (v.Server and CLIENT) then continue end
			if (!v.Convar ) then continue end --since some settings might not have associated convar values
			if (!ConVarExists(k)) then continue end

			local convar = GetConVar(k)
			local value = 0

			if (kind == MediaPlayer.Type.INT) then
				value = convar:GetInt()
			elseif (kind == MediaPlayer.Type.STRING ) then
				value = convar:GetString()
			elseif (kind == MediaPlayer.Type.BOOL ) then
				value = convar:GetBool()
			end

			v.Value = value
			MediaPlayer.Settings[k][kind] = v

			print("set convar " .. k .. " to ", v.Value )
		end
	end
end

function MediaPlayer.SetConvars()
	for k,keys in pairs(MediaPlayer.Settings) do
		for kind,v in pairs(keys) do
			if (v.Server and CLIENT) then continue end
			if (!v.Convar ) then continue end --since some settings might not have associated convar values
			if (!ConVarExists(k)) then continue end

			local convar = GetConVar(k)
			if (kind == MediaPlayer.Type.INT) then
				convar:SetInt(v.Value)
			elseif (kind == MediaPlayer.Type.STRING) then
				convar:SetString(v.Value)
			elseif (kind == MediaPlayer.Type.BOOL) then
				convar:SetBool(v.Value)
			else
				convar:SetInt(v.Value)
			end

			print("set convar " .. k .. " to ", v.Value )
		end
	end
end

if (SERVER) then
	concommand.Add("media_resync_convars", function(ply, cmd, args )
		MediaPlayer.ResyncConvars()

		if (!ply:IsAdmin()) then
			ply:SendAdminSettings()
			return
		end
	end)
end

--[[
loads our settings
--]]

if (SERVER) then
	function MediaPlayer.LoadSettings()
		if (!file.IsDir("lyds", "DATA")) then return end
		if (!file.Exists("lyds/settings.json", "DATA")) then return end

		local settings = util.JSONToTable( file.Read("lyds/settings.json") )

		for k,keys in pairs(settings) do
			for kind,v in pairs(keys) do

				if (!MediaPlayer.Settings[k]) then continue end
				if (!MediaPlayer.Settings[k][kind]) then continue end

				local tab = MediaPlayer.Settings[k][kind]
				tab.Value = v.Value

				if (kind == MediaPlayer.Types.BOOL) then
					tab.Value = ( v.Value == 1 or v.Value == true )
				elseif (kind == MediaPlayer.Types.TABLE ) then
					for key,index in pairs(v.Value) do
						tab.Value[key] = index
					end
				else
					tab.Value = v.Value
				end

				MediaPlayer.Settings[k][kind] = tab
			end
		end
	end

	concommand.Add("media_load_settings", function()
		MediaPlayer.LoadSettings()
	end)
end

--[[
loads our client settings
--]]

if (CLIENT) then
	function MediaPlayer.LoadSettings()
		if (!file.IsDir("lyds", "DATA")) then return end
		if (!file.Exists("lyds/settings_client.json", "DATA")) then return end
		local settings = util.JSONToTable( file.Read("lyds/settings_client.json") )

		for k,keys in pairs(settings) do
			for kind,v in pairs(keys) do
				if (!MediaPlayer.Settings[k]) then continue end
				if (!MediaPlayer.Settings[k][kind]) then continue end
				if (kind == MediaPlayer.Type.TABLE and MediaPlayer.Settings[k][kind].DefValue.__unpack) then
					for j,_k in pairs(v.Value) do
						v.Value[j] = MediaPlayer.Settings[k][kind].DefValue.__unpack(MediaPlayer.Settings[k][kind], j, _k)
					end
				end

				local tab = MediaPlayer.Settings[k][kind]

				if (kind == MediaPlayer.Types.BOOL) then
					tab.Value = ( v.Value == 1 or v.Value == true )
				elseif (kind == MediaPlayer.Types.TABLE ) then
					for key,index in pairs(v.Value) do
						tab.Value[key] = index
					end
				else
					tab.Value = v.Value
				end

				MediaPlayer.Settings[k][kind] = tab
			end
		end
	end

	concommand.Add("media_cl_load_settings", function()
		MediaPlayer.LoadSettings()
	end)
end


--[[
Saves our settings
--]]

if (SERVER) then
	function MediaPlayer.SaveSettings()
		if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end
		local values = {}

		for k,keys in pairs(MediaPlayer.Settings) do
			for kind,v in pairs(keys) do

				if (!v.Server and SERVER) then continue end
				if (!values[k]) then values[k] = {} end


				if (kind == MediaPlayer.Type.INT ) then
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
		MediaPlayer.SaveSettings()
	end)
end

--[[
Saves our client settings
--]]

if (CLIENT) then
	function MediaPlayer.SaveSettings()
		if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

		local values = {}

		for k,keys in pairs(MediaPlayer.Settings) do
			for kind,v in pairs(keys) do
				if (v.Server and CLIENT) then continue end

				if (!values[k]) then values[k] = {} end

				if ( kind == MediaPlayer.Type.TABLE and MediaPlayer.Settings[k][kind].DefValue.__pack) then
					for j,_k in pairs(v.Value) do
						v.Value[j] = MediaPlayer.Settings[k][kind].DefValue.__pack(MediaPlayer.Settings[k][kind], j, _k)
					end
				end

				if (kind == MediaPlayer.Type.INT ) then
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
		MediaPlayer.SaveSettings()
	end)
end

--So we can actually add our settings when all of this code has executed, but only if we haven't loaded them already
if (table.IsEmpty(MediaPlayer.Settings)) then
	hook.Run("MediaPlayer.SettingsLoaded") --this is the hook you would attach a func too
end
