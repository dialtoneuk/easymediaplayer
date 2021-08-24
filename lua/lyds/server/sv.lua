--[[
	Network Strings
	---------------------------------------------------------------------------
--]]

util.AddNetworkString("MediaPlayer.SendPlaylist")
util.AddNetworkString("MediaPlayer.SendCurrentVideo")
util.AddNetworkString("MediaPlayer.RequestAdminSettings")
util.AddNetworkString("MediaPlayer.SendAdminSettings")
util.AddNetworkString("MediaPlayer.SetAdminSettings")
util.AddNetworkString("MediaPlayer.SearchQuery")
util.AddNetworkString("MediaPlayer.SendSearchResults")
util.AddNetworkString("MediaPlayer.SendHistory")
util.AddNetworkString("MediaPlayer.SendHistoryForVideo")
util.AddNetworkString("MediaPlayer.RequestHistory")
util.AddNetworkString("MediaPlayer.SendHistoryData")
util.AddNetworkString("MediaPlayer.End")
util.AddNetworkString("MediaPlayer.NewVote")
util.AddNetworkString("MediaPlayer.EndVote")
util.AddNetworkString("MediaPlayer.SendMessage")
util.AddNetworkString("MediaPlayer.SendPersonalHistory")
util.AddNetworkString("MediaPlayer.SendBlacklist")
util.AddNetworkString("MediaPlayer.CreateWarningBox")
util.AddNetworkString("MediaPlayer.GetDefaultPreset")
util.AddNetworkString("MediaPlayer.RequestDefaultPreset")
util.AddNetworkString("MediaPlayer.ApplyDefaultPreset")
util.AddNetworkString("MediaPlayer.RefreshDefaultPreset")
util.AddNetworkString("MediaPlayer.AdminRefreshDefaultPreset")
util.AddNetworkString("MediaPlayer.SendPresetToServer")

--[[
	Net Receives
	---------------------------------------------------------------------------
--]]

--TODO: Rewrite to support multiple medai types. Currently only search youtube.
net.Receive("MediaPlayer.SearchQuery",function(len, ply)

	if (MediaPlayer.HasCooldown(ply, "Search")) then return end

	local query = net.ReadString()
	local setting = MediaPlayer.GetSetting("search_result_count")

	MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.CopyCooldown("Search") )

	MediaPlayer.YoutubeSearch(query, function(data)
		local results = {}

		for k,v in pairs(data) do
			results[v.id.videoId] = {
				Video = v.id.videoId,
				Title = v.snippet.title,
				Creator = v.snippet.channelTitle,
				Thumbnail = v.snippet.thumbnails.default.url,
			}
		end

		net.Start("MediaPlayer.SendSearchResults")
		net.WriteTable(results)
		net.Send(ply)
	end, setting.Value)
end)

--sends the admin settings to a player, checks if they are an admin inside the function.
net.Receive("MediaPlayer.RequestAdminSettings",function(len, ply)
	ply:SendAdminSettings()
end)

--sends the player the initial preset and applys it
net.Receive("MediaPlayer.GetDefaultPreset",function(len, ply)

	if (!file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	MediaPlayer.SendDefaultPreset(ply) --sends the usmg "ApplyDefaultPreset"
end)

--resends the default preset to the admin (does not apply once its send back)
net.Receive("MediaPlayer.AdminRefreshDefaultPreset",function(len, ply)

	if (!ply:IsAdmin()) then return end
	if (!file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	MediaPlayer.SendDefaultPreset(ply, "RefreshDefaultPreset")
	-- above sends the "RefreshDefaultPreset" which does not auto apply the preset only updates the clients server.json
end)

--checks if a user has joined before and if they haven't, send them the initial preset.
net.Receive("MediaPlayer.RequestDefaultPreset",function(len, ply)

	if (!file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	if (MediaPlayer.Joinlist == nil) then
		local tab = {}

		if (file.Exists("lyds/join_list.json", "DATA")) then
			tab = util.JSONToTable( file.Read("lyds/join_list.json", "DATA"))
		end

		MediaPlayer.Joinlist = tab
	end

	if MediaPlayer.Joinlist[ ply:SteamID() ] != nil then
	 	return
	end

	print("sending default preset to player: " .. ply:GetName() )

	MediaPlayer.SendDefaultPreset(ply)
	MediaPlayer.Joinlist[ ply:SteamID() ] = {
		Name = ply:GetName(),
		Date = util.DateStamp()
	}
end)

--This receives a preset from an admin and sets it as an initial preset. A preset which is sent to all new users who haven't joined before.
net.Receive("MediaPlayer.SendPresetToServer", function(len, ply)

	if (!ply:IsAdmin()) then
		warning("a unadmined player is sending admin hooks: " , ply:GetName() )
		return
	end

	local tab = net.ReadTable()

	if (table.IsEmpty(tab)) then error("table recieved is empty") end

	tab.Locked = true

	if (tab.Settings == nil ) then error("bad tab") end

	--just incase pack and unpack statements are included
	for k,v in pairs(tab.Settings) do
		if (type(v) == "table") then
			for index,_ in pairs(v) do
				if (string.sub(index, 1, 2 ) == "__") then
					v[k][index] = nil
				end
			end
		end
	end

	print("writing initial preset")
	file.Write("lyds/presets/server_preset.json", util.TableToJSON(tab) )
end)

--Sets the admins settings to those the admin provides
net.Receive("MediaPlayer.SetAdminSettings",function(len, ply)
	if (!ply:IsAdmin()) then return end

	local tab = net.ReadTable()

	for k,v in pairs(tab) do

		if (MediaPlayer.Settings[k] == nil ) then
			errorBad("player with the steam id of " .. ply:SteamID() .. " has tried to add settings")
		end


		MediaPlayer.Settings[k] = v
	end

	print("admin " .. ply:GetName() .. " has changed setting values at " .. util.DateStamp())
	MediaPlayer.SetConvars()

	for k,v in pairs(player.GetAll()) do
		if (!v:IsAdmin()) then continue end

		v:SendAdminSettings()

		if (MediaPlayer.IsSettingTrue("announce_settings")) then
			v:SendMessage("Admin settings have been updated by " .. ply:GetName()  .. " refreshing settings panel...")
		end

		v:ConCommand("settings_create")
	end
end)

--[[
	Server Hooks
	---------------------------------------------------------------
--]]

--registers various systems needed by easy media and starts the cooldown loop as well as the vote loop
hook.Add("MediaPlayer.SettingsPostLoad","MediaPlayer.LoadInternals", function()

	--loads custom tips from settings
	MediaPlayer.LoadCustomTips()
	MediaPlayer.LoadHistory()
	MediaPlayer.LoadBlacklist()
	MediaPlayer.LoadChatCommands()
	MediaPlayer.LoadCooldowns()
	MediaPlayer.LoadVotes()

	--this is where cooldown loop begins
	MediaPlayer.CooldownLoop()

	--this is where the tip loop begins
	if ( MediaPlayer.GetSetting("tips_enabled").Value) then
		MediaPlayer.DisplayTip()
	end
end)

--allows our chat commands to be parsed/executed
hook.Add("PlayerSay", "MediaPlayer.PlayerSay", function(ply, msg, teamchat)
	msg = string.lower(msg)
	if ( MediaPlayer.ParseCommand( ply, msg ) == false ) then
		return msg
	else
		return ""
	end
end)

--Sends a warning to all admins which are online when the first bad error occurs
hook.Add("OnFirstBadError","MediaPlayer.OnFirstBadError", function(err)

	local f = function()
		for k,v in pairs(player.GetAll()) do

			if (!IsValid(v)) then continue end
			if (!v:IsAdmin() ) then continue end

			v:SendMediaWarningBox("There has been an bad error! Please check the admin panel inside the error log to see what occured! \n\n error: " .. err[1],"Oh no!")
		end
	end

	pcall(f)
end)

--Does our initial spawn
hook.Add("PlayerInitialSpawn","MediaPlayer.InitialSpawn",function(ply, transition)
	ply:DoInitialSpawn()
end)

--[[
	Console commands
---------------------------------------------------------------------------
--]]

--starts a vote, the first argument is the name of the vote and it is defined in sv_media_voting.lua
concommand.Add("media_start_vote", function(ply, cmd, args)
	if (MediaPlayer.HasCooldown(ply, "Vote")) then
		ply:SendMessage("You have started a vote too recently!")
		return
	end

	--if there is no current vote
	if (!table.IsEmpty(MediaPlayer.CurrentVideo)) then
		if ( args[1] == nil or args[1] == "") then return end

		--if this vote doesn't exist
		if (!MediaPlayer.Votes[args[1]]) then return end
		if (MediaPlayer.HasCurrentVote()) then return end

		--add a cooldown to the activator so they can't spam vote
		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.CopyCooldown("Vote") )

		--start the vote
		MediaPlayer.StartVote(args[1], ply )
	end
end)

--reloads just our cooldowns
concommand.Add("media_reload_cooldowns", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadCooldowns()
end)

--reloads just our chat commands
concommand.Add("media_reload_chatcommands", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadChatCommands()
end)

--reloads our votes
concommand.Add("media_reload_votes", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadVotes()
end)

--reloads our blacklist
concommand.Add("media_reload_blacklist", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.SendBlacklist(ply)
end)

--requests the personal history of a user, useless with out the search panel opened
--TODO: Change into net
concommand.Add("media_request_personal_history", function(ply, cmd, args)
	if (!args[1]) then return end
	if (MediaPlayer.HasCooldown(ply, "History")) then return end

	local page = math.abs(tonumber(args[1]) - 1)
	local setting = MediaPlayer.GetSetting("media_history_max")

	local data = ply:GetPersonalHistory(setting.Value, page * setting.Value )

	if (data == nil or table.IsEmpty(data)) then return end

	MediaPlayer.SendPersonalHistoryData(ply, data)
	MediaPlayer.AddPlayerCooldown(ply, MediaPlayer.CopyCooldown("History"))
end)

--requests the personal history of a server useless with out the search panel opened
--TODO: Change into net
concommand.Add("media_request_history", function(ply, cmd, args)
	if (!args[1]) then return end
	if (MediaPlayer.HasCooldown(ply, "History")) then return end

	local page = math.abs(tonumber(args[1]) - 1)
	local setting = MediaPlayer.GetSetting("media_history_max")
	local results = {}

	if (table.IsEmpty(MediaPlayer.History)) then return end

	if (table.Count(MediaPlayer.History) < ( page * setting.Value) ) then
		results = {}
	else
		local count = 0
		local start = ( page * setting.Value )
		local finish = start + setting.Value
		results = {}

		for k,v in SortedPairsByMemberValue(MediaPlayer.History, "LastPlayed", true ) do

			if (count < start ) then
				count = count + 1
				continue
			end
			if (count >= finish ) then break end

			results[k] = v
			count = count + 1
		end
	end

	if ( !table.IsEmpty(results)) then
		MediaPlayer.SendHistoryData(ply, results)
		MediaPlayer.AddPlayerCooldown(ply, MediaPlayer.CopyCooldown("History"))
	end
end)

--refreshes the admin settings
concommand.Add("media_refresh_admin_settings", function(ply)
	ply:SendAdminSettings()
end)

--reloads the playlist for all users
concommand.Add("media_reload_playlist",function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.BroadcastPlaylist()
end)

--skips a video if they are an admin
concommand.Add("media_skip_video", function(ply)
	if (ply:IsAdmin() and !table.IsEmpty(MediaPlayer.CurrentVideo)) then
		MediaPlayer.SkipVideo()

		if (MediaPlayer.IsSettingTrue("announce_admin")) then
			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Video skipped by " .. ply:GetName() .. " (admin)")
			end
		end
	end
end)

--blacklists a video if they are an admin
concommand.Add("media_blacklist_video", function(ply,cmd,args)
	if (ply:IsAdmin()) then
		if (args[1] == nil and table.IsEmpty(MediaPlayer.CurrentVideo)) then return end

		local video

		if (args[1] != nil ) then video = MediaPlayer.GetVideo(args[1]) else video = MediaPlayer.CurrentVideo end
		if (video == nil or table.IsEmpty(video)) then return end

		MediaPlayer.AddToBlacklist(video, ply )

		if (MediaPlayer.CurrentVideo.Video == video.Video) then
			MediaPlayer.SkipVideo()
		else
			MediaPlayer.RemoveVideo(video.Video)
			MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
		end

		if (MediaPlayer.IsSettingTrue("announce_admin")) then
			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Video banned by " .. ply:GetName() .. " (admin)")
			end
		end
	end
end)

--unblacklists a video if they are an admin
concommand.Add("media_unblacklist_video", function(ply, cmd, args)
	if (ply:IsAdmin() and !table.IsEmpty(MediaPlayer.Blacklist)) then

		if (args[1] == nil) then return end
		if (tonumber(args[1]) != nil) then return end
		if (MediaPlayer.Blacklist[args[1]] == nil) then return end

		local vid = MediaPlayer.Blacklist[args[1]]

		if (MediaPlayer.IsSettingTrue("announce_admin")) then
			for k,v in pairs(player.GetAll()) do
				v:SendMessage( vid.Title .. " has been unbanned by " ..  ply:GetName() .. " (admin)")
			end
		end

		MediaPlayer.Blacklist[args[1]] = nil
		MediaPlayer.SendBlacklist(ply)
	end
end)

--likes a current video
concommand.Add("media_like_video", function(ply, cmd, args)
	if (MediaPlayer.HasCooldown(ply, "Interaction")) then ply:SendMessage("You have liked a video too recently") return end
	if (args[1] == nil and table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	if (ply:GetNWBool("MediaPlayer.Engaged")) then
		ply:SendMessage("You have already engaged with this video!")
		return
	end

	local video

	if (args[1] != nil ) then video = MediaPlayer.GetVideo(args[1]) else video = MediaPlayer.CurrentVideo end

	if (video) then
		MediaPlayer.LikeVideo(video)

		for k,v in pairs(player.GetAll()) do
			MediaPlayer.SendHistoryForVideo(v, MediaPlayer.History[video.Video])

			if (MediaPlayer.IsSettingTrue("announce_likes")) then
				v:SendMessage( ply:GetName() .. " has liked this video!")
			end
		end

		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.CopyCooldown("Interaction") )

		if (!MediaPlayer.IsSettingTrue("announce_dislikes")) then
			ply:SendMessage("Video liked!")
		end


		ply:SetNWBool("MediaPlayer.Engaged", true )
	end
end)

--dislikes a current video
concommand.Add("media_dislike_video", function(ply, cmd, args)
	if (MediaPlayer.HasCooldown(ply, "Interaction")) then ply:SendMessage("You have disliked a video too recently") return end
	if (args[1] == nil and table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	if (ply:GetNWBool("MediaPlayer.Engaged")) then
		ply:SendMessage("You have already engaged with this video!")
		return
	end

	local video
	if (args[1] != nil ) then video = MediaPlayer.GetVideo(args[1]) else video = MediaPlayer.CurrentVideo end

	if (video) then
		MediaPlayer.DislikeVideo(video)

		for k,v in pairs(player.GetAll()) do
			MediaPlayer.SendHistoryForVideo(v, MediaPlayer.History[video.Video])

			if (MediaPlayer.IsSettingTrue("announce_dislikes")) then
				v:SendMessage( ply:GetName() .. " has disliked this video!")
			end
		end

		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.CopyCooldown("Interaction") )

		if (!MediaPlayer.IsSettingTrue("announce_dislikes")) then
			ply:SendMessage("Video disliked!")
		end

		local val = MediaPlayer.GetSetting("video_ban_after_dislikes").Value

		if (val != 0 and val == MediaPlayer.History[video.Video].Dislikes) then
			MediaPlayer.AddToBlacklist(video, ply )
			MediaPlayer.SkipVideo()

			if (MediaPlayer.IsSettingTrue("announce_admin")) then
				for k,v in pairs(player.GetAll()) do
					v:SendMessage("Video automatically banned as it reached over the dislike fresh hold")
				end
			end
		end

		ply:SetNWBool("MediaPlayer.Engaged", true )
	end
end)

--plays a piece of media
concommand.Add("media_play", function(ply, cmd, args)

	--if we don't have at least two arguments
	if (#args <= 1 ) then
		return
	end

	local typ = args[1] --typ refering to MediaPlayer.MediaType
	local id = args[2] --is only a url if the typ is MP3

	if (MediaPlayer.IsSettingTrue("admin_only") and !ply:IsAdmin()) then
		ply:SendMessage("Only admins can use this feature.")
		return
	end

	local vids = ply:GetVideos()
	local videoCount = table.Count(vids)
	local setting = MediaPlayer.GetSetting("player_max_videos")

	--check if this user already has loads of videos
	if (videoCount >= setting.Value and (!ply:IsAdmin() or !MediaPlayer.IsSettingTrue("admin_ignore_limits") ) ) then
		ply:SendMessage("You are allowed a maximum of " .. setting.Value .. " in the playlist. You have " .. videoCount  .. "." )
		return
	end

	--get a copy of the video base
	local video = MediaPlayer.GetNewVideo()
	video.Video = args[2] --set video id
	video.Owner = ply --set owner
	video.Position =  MediaPlayer.Count or 1 --set position
	video.StartTime = CurTime()

	if (typ == MediaPlayer.MediaType.YOUTUBE or typ == MediaPlayer.MediaType.YOUTUBE_MUSIC ) then

		video.Type = MediaPlayer.MediaType.YOUTUBE

		if (typ == MediaPlayer.MediaType.YOUTUBE_MUSIC) then
			video.Type = MediaPlayer.MediaType.YOUTUBE_MUSIC
		end

		video.Custom = {
			UniqueID = MediaPlayer.GenerateSafeID(video.Video)
		}

		if (!MediaPlayer.CanSubmitVideo(video.Video, ply)) then
			return
		end

		MediaPlayer.GetYoutubeVideoInfo(video, function(returnedVideo)

			if (returnedVideo == false ) then
				if (!IsValid(video.Owner)) then return end
				video.Owner:SendMessage("There was something wrong with that video! Please try another one")
				return
			end

			if ( returnedVideo.Duration <= 0 ) then

				if (!IsValid(video.Owner)) then return end
				video.Owner:SendMessage("There was something wrong with that video! Please try another one")
				return
			end

			if ( returnedVideo.Duration > MediaPlayer.GetSetting("video_max_duration").Value ) then
				if (!IsValid(video.Owner)) then return end
				video.Owner:SendMessage("This video is too long! Please select another one")
				return
			end

			MediaPlayer.AddVideo(video.Video, video)
			MediaPlayer.AddPlayerCooldown(video.Owner, MediaPlayer.CopyCooldown("Play"))

			ply:SendMessage("Youtube video added!")
			MediaPlayer.Begin(video)
		end)
	elseif (typ == MediaPlayer.MediaType.MP3) then
		if (!MediaPlayer.ValidMediaUrl(id)) then
			print("invalid url given: " .. id)
			return
		end

		--we need to set the video id to something unique as this isn't just a video its a direct link
		video.Video = MediaPlayer.GenerateSafeID(id)
		video.Custom = {
			Url = id
		}

		--this will check if the given link is valid to the server
		MediaPlayer.IsNot404(id, function(result)
			if (!result) then
				if (!IsValid(video.Owner)) then return end
				video.Owner:SendMessage("There was something wrong with that mp3 link! Please try another one")
				return
			end

			if (!MediaPlayer.CanSubmitVideo(video.Video, ply)) then
				return
			end
		end)
	end
end)

--deletes a video if the they are an admin, first argument is video id inside the Playlist global table
concommand.Add("media_delete", function(ply, cmd, args)
	if (!args[1]) then return end
	if (!ply:IsAdmin()) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (!table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == args[1]) then return end

	MediaPlayer.RemoveVideo(args[1])

	if (MediaPlayer.IsSettingTrue("announce_admin")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Video deleted by admin (" .. ply:GetName() .. ")")
		end
	end

	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes a video from the playlist if the player owns it
concommand.Add("media_remove", function(ply, cmd, args)
	if (!args[1]) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (!table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == args[1]) then return end

	MediaPlayer.RemovePlayerVideo(args[1])
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes all a players videos
concommand.Add("media_remove_all", function(ply, cmd, args)
	MediaPlayer.RemovePlayerVideos(ply)
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
end)

--removes all a players videos if they are an admin
concommand.Add("media_delete_all", function(ply, cmd, args)

	if (!ply:IsAdmin()) then return end
end)