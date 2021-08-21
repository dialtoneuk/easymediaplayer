
--returns a string
function MediaPlayer.PackDefaultPresets()
	local tab = {}
	local str = "MediaPlayerPresets = {\n"

	if (!file.IsDir("data/presets/", "thirdparty")) then
		warning("data/presets/ not found in addon directory")
		return
	end

	local files = file.Find("data/presets/*.json", "thirdparty")

	for k,v in pairs(files) do

		v = string.Replace(v, " ", "_")
		tab[ v ] = file.Read("data/presets/" .. v , "thirdparty")
	end

	for k,v in pairs(tab) do
		str = str .. string.format("\t['%s'] = [[%s]],\n", k, v )
	end

	str = str .. "}"

	return str
end

function MediaPlayer.SavePreset(filename, preset)

	if (preset.Settings == nil ) then error("bad preset") end

	for k,v in pairs(preset.Settings) do

		if (type(v) == "table") then

			local set = MediaPlayer.GetSetting(k).DefValue
			for key,val in pairs(v) do

				if (set.__pack != nil and string.sub(key, 1, 2) != "__" ) then
					v[key] = set.__pack(v[key], key, val )
				end

				if (string.sub(key, 1, 2) == "__") then
					v[key] = nil
					continue
				end
			end
		end
	end

	filename = string.Replace(filename, ".json", "")
	file.Write("lyds/presets/" .. filename .. ".json", util.TableToJSON(preset) )
end

function MediaPlayer.ApplyPreset(preset)

	if (preset.Settings == nil ) then error("bad preset") end

	for k,v in pairs(preset.Settings) do

		if (type(v) == "table") then

			local set = MediaPlayer.GetSetting(k).DefValue
			for key,val in pairs(v) do

				if (set.__unpack != nil and string.sub(key, 1, 2) != "__" ) then
					v[key] = set.__unpack(v[key], key, val )
				end

				if (string.sub(key, 1, 2) == "__") then
					v[key] = nil
					continue
				end
			end

			MediaPlayer.ChangeSetting(k, table.Copy(v))
		else
			MediaPlayer.ChangeSetting(k, v)
		end
	end
end

function MediaPlayer.WriteDefaultPresets()

	local files = MediaPlayer.GetPackedPresets()

	if (table.IsEmpty(files)) then
		print("no files found")
		return
	end

	for k,v in pairs(files) do
		if (file.Exists("lyds/presets/" .. k, "DATA" )) then print(k .. " already exists in folder")  continue end
		if (!file.IsDir("lyds/presets/", "DATA")) then file.CreateDir("lyds/presets/") end

		print("writing default preset file " .. k .. " into data/lyds/presets")
		file.Write("lyds/presets/" .. k, v)
	end
end

function MediaPlayer.PrintDefaultPresets()

	if (!file.IsDir("lyds/", "DATA")) then file.CreateDir("lyds/") end

	local str = MediaPlayer.PackDefaultPresets()
	str = "--autogenerated " .. util.DateStamp() .. "\n\n" .. str

	file.Write("lyds/default_presets.txt", str)

	print("Success!")
	print("-- open garrysmod/garrysmod/data/lyds/default_presets.txt for output")
	print("-- copy content of .txt into garrysmod/addons/<addon_name>/lua/autorun/presets.lua")
end

function MediaPlayer.GetPackedPresets()

	--this global is loaded from autorun
	if ( MediaPlayerPresets == nil or table.IsEmpty(MediaPlayerPresets )) then
		return
	end

	return MediaPlayerPresets;
end

function MediaPlayer.RequestDefaultPreset()

	net.Start("MediaPlayer.RequestDefaultPreset")
	net.SendToServer()
end

function MediaPlayer.RefreshDefaultPreset()

	net.Start("MediaPlayer.RequestRefreshDefaultPreset")
		--nope
	net.SendToServer()
end

function MediaPlayer.RequestDefaultInitialPreset()

	net.Start("MediaPlayer.RequestDefaultInitialPreset")
	net.SendToServer()
end

function MediaPlayer.ApplyInitialPreset(preset)

	if (!MediaPlayer.LocalPlayer:IsAdmin()) then return end

	if (table.IsEmpty(preset) or preset.Settings == nil ) then
		error("bad preset")
	end

	for k,v in pairs(preset.Settings) do

		if (type(v) == "table") then

			local set = MediaPlayer.GetSetting(k).DefValue
			for key,val in pairs(v) do

				if (set.__pack != nil and string.sub(key, 1, 2) != "__" ) then
					v[key] = set.__pack(v[key], key, val )
				end

				if (string.sub(key, 1, 2) == "__") then
					v[key] = nil
					continue
				end
			end
		end
	end

	print("sending initial preset to server")
	net.Start("MediaPlayer.ApplyInitialPreset")
		net.WriteTable(preset)
	net.SendToServer()
end