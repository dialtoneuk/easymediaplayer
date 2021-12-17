--[[
Network Strings
---------------------------------------------------------------------------
--]]
util.AddNetworkString("LydsPlayer.SendPlaylist")
util.AddNetworkString("LydsPlayer.SendCurrentVideo")
util.AddNetworkString("LydsPlayer.RequestAdminSettings")
util.AddNetworkString("LydsPlayer.SendMediaPlayerAdminSettings")
util.AddNetworkString("LydsPlayer.SetAdminSettings")
util.AddNetworkString("LydsPlayer.SearchQuery")
util.AddNetworkString("LydsPlayer.SendSearchResults")
util.AddNetworkString("LydsPlayer.SendSession")
util.AddNetworkString("LydsPlayer.SendSessionForVideo")
util.AddNetworkString("LydsPlayer.RequestHistory")
util.AddNetworkString("LydsPlayer.SendSessionChunk")
util.AddNetworkString("LydsPlayer.End")
util.AddNetworkString("LydsPlayer.NewVote")
util.AddNetworkString("LydsPlayer.EndVote")
util.AddNetworkString("LydsPlayer.SendMediaPlayerMessage")
util.AddNetworkString("LydsPlayer.SendPersonalSession")
util.AddNetworkString("LydsPlayer.SendBlacklist")
util.AddNetworkString("LydsPlayer.CreateWarningBox")
util.AddNetworkString("LydsPlayer.GetDefaultPreset")
util.AddNetworkString("LydsPlayer.RequestDefaultPreset")
util.AddNetworkString("LydsPlayer.ApplyDefaultPreset")
util.AddNetworkString("LydsPlayer.RefreshDefaultPreset")
util.AddNetworkString("LydsPlayer.AdminRefreshDefaultPreset")
util.AddNetworkString("LydsPlayer.SendPresetToServer")
util.AddNetworkString("LydsPlayer.SendHistory")
util.AddNetworkString("LydsPlayer.EnabledMediaTypes")

--[[
Net Receives
---------------------------------------------------------------------------
--]]
--TODO: Rewrite to support multiple medai types. Currently only search youtube.
net.Receive("LydsPlayer.SearchQuery", function(len, ply)
	if (LydsPlayer.HasCooldown(ply, "Search")) then
		ply:SendMediaPlayerMessage("Please wait a bit before searching again")

		return
	end

	local query = net.ReadString()
	local typ = net.ReadString()
	local setting = LydsPlayer.GetSetting("search_result_count")
	LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Search"))

	local callback = function(data)
		local results = {}

		for k, v in pairs(data) do
			results[v.id.videoId] = {
				Video = v.id.videoId,
				Title = v.snippet.title,
				Type = typ,
				Creator = v.snippet.channelTitle,
				Description = v.snippet.description or "No description...",
				Thumbnail = v.snippet.thumbnails.default.url,
			}
		end

		net.Start("LydsPlayer.SendSearchResults")
		net.WriteTable(results)
		net.WriteString(typ)
		net.Send(ply)
	end

	if (typ == LydsPlayer.MediaType.YOUTUBE) then
		LydsPlayer.YoutubeSearch(query, callback, setting.Value)
	else
		--more here
		print("unimplemented")
	end
end)

--sends the admin settings to a player, checks if they are an admin inside the function.
net.Receive("LydsPlayer.RequestAdminSettings", function(len, ply)
	ply:SendMediaPlayerAdminSettings()
end)

--sends the player the initial preset and applys it
net.Receive("LydsPlayer.GetDefaultPreset", function(len, ply)
	if (not file.Exists("lyds/presets/server_preset.json", "DATA")) then return end
	LydsPlayer.SendDefaultPreset(ply) --sends the usmg "ApplyDefaultPreset"
end)

--resends the default preset to the admin (does not apply once its send back)
net.Receive("LydsPlayer.AdminRefreshDefaultPreset", function(len, ply)
	if (not ply:IsAdmin()) then return end
	if (not file.Exists("lyds/presets/server_preset.json", "DATA")) then return end
	LydsPlayer.SendDefaultPreset(ply, "Refresh")
end)

-- above sends the "RefreshDefaultPreset" which does not auto apply the preset only updates the clients server.json
--checks if a user has joined before and if they haven't, send them the initial preset.
net.Receive("LydsPlayer.RequestDefaultPreset", function(len, ply)
	if (not file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	if (LydsPlayer.Joinlist == nil) then
		local tab = {}

		if (file.Exists("lyds/join_list.json", "DATA")) then
			tab = util.JSONToTable(file.Read("lyds/join_list.json", "DATA"))
		end

		LydsPlayer.Joinlist = tab
	end

	if LydsPlayer.Joinlist[ply:SteamID()] ~= nil then return end
	print("sending default preset to player: " .. ply:GetName())
	LydsPlayer.SendDefaultPreset(ply)

	LydsPlayer.Joinlist[ply:SteamID()] = {
		Name = ply:GetName(),
		Date = util.DateStamp()
	}
end)

--This receives a preset from an admin and sets it as an initial preset. A preset which is sent to all new users who haven't joined before.
net.Receive("LydsPlayer.SendPresetToServer", function(len, ply)
	if (not ply:IsAdmin()) then
		warning("a unadmined player is sending admin hooks: ", ply:GetName())

		return
	end

	local tab = net.ReadTable()

	if (table.IsEmpty(tab)) then
		error("table recieved is empty")
	end

	tab.Locked = true

	if (tab.Settings == nil) then
		error("bad tab")
	end

	--just incase pack and unpack statements are included
	for k, v in pairs(tab.Settings) do
		if (type(v) == "table") then
			for index, _ in pairs(v) do
				if (string.sub(index, 1, 2) == "__") then
					v[k][index] = nil
				end
			end
		end
	end

	print("writing initial preset")
	file.Write("lyds/presets/server_preset.json", util.TableToJSON(tab))
end)

--Sets the admins settings to those the admin provides
net.Receive("LydsPlayer.SetAdminSettings", function(len, ply)
	if (not ply:IsAdmin()) then return end
	local tab = net.ReadTable()

	for k, v in pairs(tab) do
		if (LydsPlayer.Settings[k] == nil) then
			errorBad("player with the steam id of " .. ply:SteamID() .. " has tried to add settings")
		end

		LydsPlayer.Settings[k] = v
	end

	print("admin " .. ply:GetName() .. " has changed setting values at " .. util.DateStamp())
	LydsPlayer.SetConvars()
	local enabled = LydsPlayer.GetEnabledMediaTypes()

	for k, v in pairs(player.GetAll()) do
		LydsPlayer.SendEnabledMediaTypes(v, enabled)
		if (not v:IsAdmin()) then continue end
		v:SendMediaPlayerAdminSettings()

		if (LydsPlayer.IsSettingTrue("announce_settings")) then
			v:SendMediaPlayerMessage("Admin settings have been updated by " .. ply:GetName() .. " refreshing settings panel...")
		end

		v:ConCommand("settings_create")
	end
end)

--[[
Server Hooks
---------------------------------------------------------------
--]]
--registers various systems needed by easy media and starts the cooldown loop as well as the vote loop
hook.Add("LydsPlayer.SettingsPostLoad", "LydsPlayer.LoadInternals", function()
	--loads custom tips from settings
	LydsPlayer.LoadCustomTips()
	LydsPlayer.LoadBlacklist()
	LydsPlayer.LoadChatCommands()
	LydsPlayer.LoadCooldowns()
	LydsPlayer.LoadVotes()
	--Create sql table if it does not exist
	LydsPlayer.CheckSqlTableExists()
	--this is where cooldown loop begins
	LydsPlayer.CooldownLoop()

	--this is where the tip loop begins
	if (LydsPlayer.GetSetting("tips_enabled").Value) then
		LydsPlayer.DisplayTip()
	end
end)

--allows our chat commands to be parsed/executed
hook.Add("PlayerSay", "LydsPlayer.PlayerSay", function(ply, msg, teamchat)
	msg = string.lower(msg)

	if (LydsPlayer.ParseCommand(ply, msg) == false) then
		return msg
	else
		return ""
	end
end)

local errorh = function(err)
	local f = function()
		err[1] = err[1] or ""
		local suffix = ""

		if (#err[1] > 64) then
			err[1] = string.sub(err[1], 1, 64)
			suffix = " (cut after 64 characters check log/console)"
		end

		--wont spam
		if (MediaPlayer and LydsPlayer.LastError ~= err[1]) then
			LydsPlayer.LastError = err[1]
		end

		for k, v in pairs(player.GetAll()) do
			if (not IsValid(v)) then continue end
			if (not v:IsAdmin()) then continue end
			v:SendMediaPlayerMessage("There has been an error...")
			v:SendMediaPlayerMessage(err[1] .. suffix .. "\n", true)
			v:SendMediaPlayerMessage("[" .. LydsPlayer.Name .. " v" .. LydsPlayer.Version .. "]", true)
		end
	end

	pcall(f)
end

--Sends first bad error no matter what
hook.Add("OnFirstBadError", "LydsPlayer.OnFirstBadError", errorh)
hook.Add("OnBadError", "LydsPlayer.OnBadError", errorh)

--Sends a warning to all admins each time a server error occurs
hook.Add("OnWarning", "LydsPlayer.OnWarning", function(err)
	local f = function()
		err[1] = err[1] or ""
		local suffix = ""

		if (#err[1] > 32) then
			err[1] = string.sub(err[1], 1, 32)
			suffix = " (cut after 32 characters check log/console)"
		end

		--wont spam
		if (MediaPlayer and LydsPlayer.LastWarning ~= err[1]) then
			LydsPlayer.LastWarning = err[1]
		end

		for k, v in pairs(player.GetAll()) do
			if (not IsValid(v)) then continue end
			if (not v:IsAdmin()) then continue end
			v:SendMediaPlayerMessage("Something is trying to warn you...")
			v:SendMediaPlayerMessage("[START] (v" .. LydsPlayer.Version .. ")", true)
			v:SendMediaPlayerMessage(err[1] .. suffix .. "\n", true)
			v:SendMediaPlayerMessage("[END] (v" .. LydsPlayer.Version .. ")", true)
		end
	end

	pcall(f)
end)

--Does our initial spawn
hook.Add("PlayerInitialSpawn", "LydsPlayer.InitialSpawn", function(ply, transition)
	ply:MediaPlayerInitialSpawn()
	--for the search panel, sends what media types are currently enabled
	LydsPlayer.SendEnabledMediaTypes(ply, LydsPlayer.GetEnabledMediaTypes())
end)

--[[
Console commands
---------------------------------------------------------------------------
--]]
--starts a vote, the first argument is the name of the vote and it is defined in sv_media_voting.lua
concommand.Add("media_start_vote", function(ply, cmd, args)
	if (LydsPlayer.HasCooldown(ply, "Vote")) then
		ply:SendMediaPlayerMessage("You have started a vote too recently!")

		return
	end

	--if there is no current vote
	if (not table.IsEmpty(LydsPlayer.CurrentVideo)) then
		if (args[1] == nil or args[1] == "") then return end
		--if this vote doesn't exist
		if (not LydsPlayer.Votes[args[1]]) then return end
		if (LydsPlayer.HasCurrentVote()) then return end
		--add a cooldown to the activator so they can't spam vote
		LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Vote"))
		--start the vote
		LydsPlayer.StartVote(args[1], ply)
	end
end)

--reloads just our cooldowns
concommand.Add("media_reload_cooldowns", function(ply)
	if (not ply:IsAdmin()) then return end
	LydsPlayer.LoadCooldowns()
end)

--reloads just our chat commands
concommand.Add("media_reload_chatcommands", function(ply)
	if (not ply:IsAdmin()) then return end
	LydsPlayer.LoadChatCommands()
end)

--reloads our votes
concommand.Add("media_reload_votes", function(ply)
	if (not ply:IsAdmin()) then return end
	LydsPlayer.LoadVotes()
end)

--reloads our blacklist
concommand.Add("media_reload_blacklist", function(ply)
	if (not ply:IsAdmin()) then return end
	LydsPlayer.SendBlacklist(ply)
end)

--requests the personal history of a user, useless with out the search panel opened
--TODO: Change into net
concommand.Add("media_request_personal_session", function(ply, cmd, args)
	if (not args[1]) then return end
	if (LydsPlayer.HasCooldown(ply, "Session")) then return end
	local page = math.abs(tonumber(args[1]) - 1)
	local setting = LydsPlayer.GetSetting("media_history_max")
	local data = ply:GetSessionVideos(setting.Value, page * setting.Value)
	if (data == nil or table.IsEmpty(data)) then return end
	LydsPlayer.SendPersonalSessionData(ply, data)
	LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Session"))
end)

concommand.Add("media_history", function(ply, cmd, args)
	local limit = LydsPlayer.GetSetting("media_history_max")

	if (#args == 0) then
		error("must be at least one arguments: orderby (string), onlyplayer (bool), ascending (bool), page (int)")
	end

	local orderby = args[1]
	local onlyplayer = false
	local asc = false

	if (args[2] ~= nil and args[2] == "true") then
		onlyplayer = true
	end

	if (args[3] ~= nil and args[3] == "true") then
		asc = true
	end

	local page = args[4] or 0

	if (type(page) ~= "number") then
		error("page is not a number")
	end

	local results

	if (onlyplayer) then
		print("on")
		results = LydsPlayer.GetPlayerHistory(ply:SteamID(), orderby, asc, limit.Value, page)
	else
		results = LydsPlayer.GetHistory(orderby, asc, limit.Value, page)
	end

	if (results == nil) then
		results = {}
	end

	net.Start("LydsPlayer.SendHistory")
	net.WriteTable(results)
	net.WriteTable(limit)
	net.Send(ply)
end)

--requests the personal history of a server useless with out the search panel opened
--TODO: Change into net
concommand.Add("media_request_session", function(ply, cmd, args)
	if (not args[1]) then return end
	if (LydsPlayer.HasCooldown(ply, "Session")) then return end
	local page = math.abs(tonumber(args[1]) - 1)
	local setting = LydsPlayer.GetSetting("media_history_max")
	local results = {}
	if (table.IsEmpty(LydsPlayer.Session)) then return end

	if (table.Count(LydsPlayer.Session) < (page * setting.Value)) then
		results = {}
	else
		local count = 0
		local start = (page * setting.Value)
		local finish = start + setting.Value
		results = {}

		for k, v in SortedPairsByMemberValue(LydsPlayer.Session, "LastPlayed", true) do
			if (count < start) then
				count = count + 1
				continue
			end

			if (count >= finish) then break end
			results[k] = v
			count = count + 1
		end
	end

	if (not table.IsEmpty(results)) then
		LydsPlayer.SendSessionChunk(ply, results)
		LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Session"))
	end
end)

--refreshes the admin settings
concommand.Add("media_refresh_admin_settings", function(ply)
	ply:SendMediaPlayerAdminSettings()
end)

--reloads the playlist for all users
concommand.Add("media_reload_playlist", function(ply)
	if (not ply:IsAdmin()) then return end
	LydsPlayer.BroadcastPlaylist()
end)

--skips a video if they are an admin
concommand.Add("media_skip_video", function(ply)
	if (ply:IsAdmin() and not table.IsEmpty(LydsPlayer.CurrentVideo)) then
		LydsPlayer.SkipVideo()

		if (LydsPlayer.IsSettingTrue("announce_admin")) then
			for k, v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Video skipped by " .. ply:GetName() .. " (admin)")
			end
		end
	end
end)

--blacklists a video if they are an admin
concommand.Add("media_blacklist_video", function(ply, cmd, args)
	if (ply:IsAdmin()) then
		if (args[1] == nil and table.IsEmpty(LydsPlayer.CurrentVideo)) then return end
		local video

		if (args[1] ~= nil) then
			video = LydsPlayer.GetVideo(args[1])
		else
			video = LydsPlayer.CurrentVideo
		end

		if (video == nil or table.IsEmpty(video)) then return end
		LydsPlayer.AddToBlacklist(video, ply)

		if (LydsPlayer.CurrentVideo.Video == video.Video) then
			LydsPlayer.SkipVideo()
		else
			LydsPlayer.RemoveVideo(video.Video)
			LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
		end

		if (LydsPlayer.IsSettingTrue("announce_admin")) then
			for k, v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Video banned by " .. ply:GetName() .. " (admin)")
			end
		end
	end
end)

--unblacklists a video if they are an admin
concommand.Add("media_unblacklist_video", function(ply, cmd, args)
	if (ply:IsAdmin() and not table.IsEmpty(LydsPlayer.Blacklist)) then
		if (args[1] == nil) then return end
		if (tonumber(args[1]) ~= nil) then return end
		if (LydsPlayer.Blacklist[args[1]] == nil) then return end
		local vid = LydsPlayer.Blacklist[args[1]]

		if (LydsPlayer.IsSettingTrue("announce_admin")) then
			for k, v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage(vid.Title .. " has been unbanned by " .. ply:GetName() .. " (admin)")
			end
		end

		LydsPlayer.Blacklist[args[1]] = nil
		LydsPlayer.SendBlacklist(ply)
	end
end)

--likes a current video
concommand.Add("media_like_video", function(ply, cmd, args)
	if (LydsPlayer.HasCooldown(ply, "Interaction")) then
		ply:SendMediaPlayerMessage("You have liked a video too recently")

		return
	end

	if (args[1] == nil and table.IsEmpty(LydsPlayer.CurrentVideo)) then return end

	if (ply:GetNWBool("LydsPlayer.Engaged")) then
		ply:SendMediaPlayerMessage("You have already engaged with this video!")

		return
	end

	local video

	if (args[1] ~= nil) then
		video = LydsPlayer.GetVideo(args[1])
	else
		video = LydsPlayer.CurrentVideo
	end

	if (video) then
		LydsPlayer.LikeVideo(video)

		for k, v in pairs(player.GetAll()) do
			LydsPlayer.SendSessionForVideo(v, LydsPlayer.Session[video.Video])

			if (LydsPlayer.IsSettingTrue("announce_likes")) then
				v:SendMediaPlayerMessage(ply:GetName() .. " has liked this video!")
			end
		end

		LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Interaction"))

		if (not LydsPlayer.IsSettingTrue("announce_dislikes")) then
			ply:SendMediaPlayerMessage("Video liked!")
		end

		ply:SetNWBool("LydsPlayer.Engaged", true)
	end
end)

--dislikes a current video
concommand.Add("media_dislike_video", function(ply, cmd, args)
	if (LydsPlayer.HasCooldown(ply, "Interaction")) then
		ply:SendMediaPlayerMessage("You have disliked a video too recently")

		return
	end

	if (args[1] == nil and table.IsEmpty(LydsPlayer.CurrentVideo)) then return end

	if (ply:GetNWBool("LydsPlayer.Engaged")) then
		ply:SendMediaPlayerMessage("You have already engaged with this video!")

		return
	end

	local video

	if (args[1] ~= nil) then
		video = LydsPlayer.GetVideo(args[1])
	else
		video = LydsPlayer.CurrentVideo
	end

	if (video) then
		LydsPlayer.DislikeVideo(video)

		for k, v in pairs(player.GetAll()) do
			LydsPlayer.SendSessionForVideo(v, LydsPlayer.Session[video.Video])

			if (LydsPlayer.IsSettingTrue("announce_dislikes")) then
				v:SendMediaPlayerMessage(ply:GetName() .. " has disliked this video!")
			end
		end

		LydsPlayer.AddPlayerCooldown(ply, LydsPlayer.CopyCooldown("Interaction"))

		if (not LydsPlayer.IsSettingTrue("announce_dislikes")) then
			ply:SendMediaPlayerMessage("Video disliked!")
		end

		local val = LydsPlayer.GetSetting("video_ban_after_dislikes").Value

		if (val ~= 0 and val == LydsPlayer.Session[video.Video].Dislikes) then
			LydsPlayer.AddToBlacklist(video, ply)
			LydsPlayer.SkipVideo()

			if (LydsPlayer.IsSettingTrue("announce_admin")) then
				for k, v in pairs(player.GetAll()) do
					v:SendMediaPlayerMessage("Video automatically banned as it reached over the dislike fresh hold")
				end
			end
		end

		ply:SetNWBool("LydsPlayer.Engaged", true)
	end
end)

local _f = function(ply, typ, id)
	if (LydsPlayer.IsSettingTrue("admin_only") and not ply:IsAdmin()) then
		ply:SendMediaPlayerMessage("Only admins can use this feature.")
		return
	end

	local vids = ply:GetVideos()
	local videoCount = table.Count(vids)
	local setting = LydsPlayer.GetSetting("player_max_videos")

	--check if this user already has loads of videos
	if (videoCount >= setting.Value and (not ply:IsAdmin() or not LydsPlayer.IsSettingTrue("admin_ignore_limits"))) then
		ply:SendMediaPlayerMessage("You are allowed a maximum of " .. setting.Value .. " in the playlist. You have " .. videoCount .. ".")
		return
	end

	--get a copy of the video base
	local video = LydsPlayer.GetNewVideo()
	video.Video = id --set video id
	video.Owner = ply --set owner
	video.Position = LydsPlayer.Count or 1 --set position
	video.StartTime = CurTime()

	if (typ == LydsPlayer.MediaType.YOUTUBE or typ == LydsPlayer.MediaType.YOUTUBE_MUSIC) then
		video.Type = LydsPlayer.MediaType.YOUTUBE

		if (typ == LydsPlayer.MediaType.YOUTUBE_MUSIC) then
			video.Type = LydsPlayer.MediaType.YOUTUBE_MUSIC
		end

		video.Custom = {
			UniqueID = LydsPlayer.GenerateSafeID(video.Video)
		}

		if (not LydsPlayer.CanSubmitVideo(video.Video, ply)) then return end

		LydsPlayer.GetYoutubeVideoInfo(video, function(returnedVideo)
			if (returnedVideo == false) then
				if (not IsValid(video.Owner)) then return end
				video.Owner:SendMediaPlayerMessage("There was something wrong with that video! Please try another one")

				return
			end

			if (returnedVideo.Duration <= 0) then
				if (not IsValid(video.Owner)) then return end
				video.Owner:SendMediaPlayerMessage("There was something wrong with that video! Please try another one")

				return
			end

			if (returnedVideo.Duration > LydsPlayer.GetSetting("video_max_duration").Value) then
				if (not IsValid(video.Owner)) then return end
				video.Owner:SendMediaPlayerMessage("This video is too long! Please select another one")

				return
			end

			LydsPlayer.AddVideo(video.Video, video)
			LydsPlayer.AddPlayerCooldown(video.Owner, LydsPlayer.CopyCooldown("Play"))
			ply:SendMediaPlayerMessage("Youtube video added!")
			LydsPlayer.Begin(video)
		end)
	elseif (typ == LydsPlayer.MediaType.MP3) then
		if (not LydsPlayer.ValidMediaUrl(id)) then
			print("invalid url given: " .. id)

			return
		end

		--we need to set the video id to something unique as this isn't just a video its a direct link
		video.Video = LydsPlayer.GenerateSafeID(id)

		video.Custom = {
			Url = id
		}

		--this will check if the given link is valid to the server
		LydsPlayer.IsNot404(id, function(result)
			if (not result) then
				if (not IsValid(video.Owner)) then return end
				video.Owner:SendMediaPlayerMessage("There was something wrong with that mp3 link! Please try another one")

				return
			end

			if (not LydsPlayer.CanSubmitVideo(video.Video, ply)) then return end
		end)
	end
end

--plays a piece of media
concommand.Add("media_play", function(ply, cmd, args)
	--if we don't have at least two arguments
	if (#args <= 1) then return end
	local typ = args[1] --typ refering to LydsPlayer.MediaType
	local id = args[2] --is only a url if the typ is MP3

	_f(ply, typ, id)
end)

--plays a piece of media
concommand.Add("media_play_youtube", function(ply, cmd, args)
	--if we don't have at least two arguments
	if (#args == 0) then return end

	local str = args[1]

	print(str);

	str = LydsPlayer.ParseYoutubeURL(str)

	if (str == nil) then
		error("bad str")
		return
	end


	local typ = LydsPlayer.MediaType.YOUTUBE --typ refering to LydsPlayer.MediaType
	local id = args[1] --is only a url if the typ is MP3

	_f(ply, typ, id)
end)

--deletes a video if the they are an admin, first argument is video id inside the Playlist global table
concommand.Add("media_delete", function(ply, cmd, args)
	if (not args[1]) then return end
	if (not ply:IsAdmin()) then return end
	if (tonumber(args[1]) ~= nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (not table.IsEmpty(LydsPlayer.CurrentVideo) and LydsPlayer.CurrentVideo.Video == args[1]) then return end
	LydsPlayer.RemoveVideo(args[1])

	if (LydsPlayer.IsSettingTrue("announce_admin")) then
		for k, v in pairs(player.GetAll()) do
			v:SendMediaPlayerMessage("Video deleted by admin (" .. ply:GetName() .. ")")
		end
	end

	LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes a video from the playlist if the player owns it
concommand.Add("media_remove", function(ply, cmd, args)
	if (not args[1]) then return end
	if (tonumber(args[1]) ~= nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (not table.IsEmpty(LydsPlayer.CurrentVideo) and LydsPlayer.CurrentVideo.Video == args[1]) then return end
	LydsPlayer.RemovePlayerVideo(args[1])
	LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes all a players videos
concommand.Add("media_remove_all", function(ply, cmd, args)
	LydsPlayer.RemovePlayerVideos(ply)
	LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes all a players videos if they are an admin
concommand.Add("media_delete_all", function(ply, cmd, args)
	if (not ply:IsAdmin()) then return end
end)