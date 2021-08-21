--[[
	Net Receives
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
util.AddNetworkString("MediaPlayer.RequestDefaultPreset")
util.AddNetworkString("MediaPlayer.RequestDefaultInitialPreset")
util.AddNetworkString("MediaPlayer.ApplyDefaultPreset")
util.AddNetworkString("MediaPlayer.RefreshDefaultPreset")
util.AddNetworkString("MediaPlayer.RequestRefreshDefaultPreset")
util.AddNetworkString("MediaPlayer.ApplyInitialPreset")

--responds to a search query
net.Receive("MediaPlayer.SearchQuery",function(len, ply)

	if (MediaPlayer.HasCooldown(ply, "Search")) then return end

	local query = net.ReadString()
	local setting = MediaPlayer.GetSetting("media_max_results")

	MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.GetNewCooldown("Search") )

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

--[[
Sends the servers settings to the client if they are an admin
--]]

net.Receive("MediaPlayer.RequestAdminSettings",function(len, ply)
	ply:SendAdminSettings()
end)

--
net.Receive("MediaPlayer.RequestDefaultPreset",function(len, ply)

	if (!file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	MediaPlayer.SendDefaultPreset(ply)
end)

net.Receive("MediaPlayer.RequestRefreshDefaultPreset",function(len, ply)

	if (!file.Exists("lyds/presets/server_preset.json", "DATA")) then return end

	MediaPlayer.SendDefaultPreset(ply, "RefreshDefaultPreset")
end)

--request the initial preset from the server
net.Receive("MediaPlayer.RequestDefaultInitialPreset",function(len, ply)

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

net.Receive("MediaPlayer.ApplyInitialPreset", function(len, ply)

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


--[[
Sets settings from the player
--]]

net.Receive("MediaPlayer.SetAdminSettings",function(len, ply)
	if (!ply:IsAdmin()) then return end

	local tab = net.ReadTable()

	for k,v in pairs(tab) do

		if (MediaPlayer.Settings[k] == nil ) then
			errorBad("player with the steam id of " .. ply:SteamID() .. " has tried to add settings")
		end

		MediaPlayer.Settings[k] = v
	end

	MediaPlayer.SetConvars()
end)

--[[

	HOOKS!

	This loads stuff which requries our settings to be loaded first
	---------------------------------------------------------------
--]]

hook.Add("MediaPlayer.SettingsPostLoad","MediaPlayer.MiscStuffLoad", function()

	--loads custom tips from settings
	MediaPlayer.LoadCustomTips()
	MediaPlayer.LoadHistory()
	MediaPlayer.LoadBlacklist()
	MediaPlayer.CooldownLoop()

	if ( MediaPlayer.GetSetting("media_tips_enabled").Value) then
		MediaPlayer.DisplayTip()
	end
end)

--[[
	Chat Commands Hook
	---------------------------------------------------------------------------
--]]

hook.Add("PlayerSay", "MediaPlayer.PlayerSay", function(ply, msg, teamchat)
	msg = string.lower(msg)
	if ( MediaPlayer.ParseCommand( ply, msg ) == false ) then
		return msg
	else
		return ""
	end
end)

--[[
	On the first bad error that of occurs, lets notify all the online admins of its occurance
	---------------------------------------------------------------------------
--]]


hook.Add("OnFirstBadError","MediaPlayer.OnFirstBadError", function(err)
	for k,v in pairs(player.GetAll()) do

		if (!IsValid(v)) then continue end
		if (!v:IsAdmin() ) then continue end

		v:SendWarningBox("There has been an bad error! Please check the admin panel inside the error log to see what occured! \n\n error: " .. err[1],"Oh no!")
	end
end)

--[[
	Do our initial spawn on dat client boy
	---------------------------------------------------------------------------
--]]

hook.Add("PlayerInitialSpawn","MediaPlayer.InitialSpawn",function(ply, transition)
	ply:DoInitialSpawn()
end)

--[[
	Chat Commands can be loaded as soon as the file has been read
	See sv_media_chatcommands.lua
	---------------------------------------------------------------------------
--]]

hook.Add("MediaPlayer.LoadedChatCommands", "MediaPlayer.LoadedChatCommands", function()
	MediaPlayer.LoadChatCommands()
end)

--[[
	Cooldowns can be loaded as soon as the file has been read
	See sv_media_cooldown.lua
	---------------------------------------------------------------------------
--]]

hook.Add("MediaPlayer.CooldownLoaded","MediaPlayer.LoadCooldowns", function()
	MediaPlayer.LoadCooldowns()
end)

--[[
	VOTES!

	Votes are defined inside the media_voting.lua file on the Server. They have a callback
	which is executed when they pass, and one when they fail.

	Its very basic, and votes will always pass if half the server agrees.

	Note: votes are activated through a console command called "Youtube_start_vote", it looks for the name of the
	vote defined inside the media_voting.lua file and creates a new vote of that type if none are currently active.

	Votes can be loaded as soon as the file has been read
	See sv_media_voting.lua
---------------------------------------------------------------------------
--]]

hook.Add("MediaPlayer.VotingLoaded", "MediaPlayer.VotingLoaded", function()
	MediaPlayer.LoadVotes()
end)

--[[
Console command to vote
--]]

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
		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.GetNewCooldown("Vote") )

		--start the vote
		MediaPlayer.StartVote(args[1], ply )
	end
end)


--[[
	Various Console commands
---------------------------------------------------------------------------
--]]

concommand.Add("media_reload_cooldowns", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadCooldowns()
end)

concommand.Add("media_reload_chatcommands", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadChatCommands()
end)

concommand.Add("media_reload_votes", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.LoadVotes()
end)

concommand.Add("media_reload_blacklist", function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.SendBlacklist(ply)
end)

--[[
Requests personal history from the server
--]]

concommand.Add("media_request_personal_history", function(ply, cmd, args)
	if (!args[1]) then return end
	if (MediaPlayer.HasCooldown(ply, "History")) then return end

	local page = math.abs(tonumber(args[1]) - 1)
	local setting = MediaPlayer.GetSetting("media_history_max")

	local data = ply:GetPersonalHistory(setting.Value, page * setting.Value )

	if (data == nil or table.IsEmpty(data)) then return end

	MediaPlayer.SendPersonalHistoryData(ply, data)
	MediaPlayer.AddPlayerCooldown(ply, MediaPlayer.GetNewCooldown("History"))
end)

--[[
Requests history from the server
--]]

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
		MediaPlayer.AddPlayerCooldown(ply, MediaPlayer.GetNewCooldown("History"))
	end
end)

--[[
Command to refresh settings
--]]

concommand.Add("media_refresh_settings", function(ply)
	ply:SendAdminSettings()
end)

--[[
Reloads the playlist for everyone
--]]

concommand.Add("media_reload_playlist",function(ply)
	if (!ply:IsAdmin()) then return end

	MediaPlayer.BroadcastPlaylist()
end)

--[[
Skips a video
--]]

concommand.Add("media_skip_video", function(ply)
	if (ply:IsAdmin() and !table.IsEmpty(MediaPlayer.CurrentVideo)) then
		MediaPlayer.SkipVideo()

		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Video skipped by admin (" .. ply:GetName() .. ")")
		end
	end
end)

--[[
Blacklists as video
--]]

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
			MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("media_playlist_limit").Value)
		end

		if (MediaPlayer.IsSettingTrue("media_announce_admin")) then
			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Video blacklisted by admin (" .. ply:GetName() .. ")")
			end
		end
	end
end)

--[[
Unblacklists as video
--]]

concommand.Add("media_unblacklist_video", function(ply, cmd, args)
	if (ply:IsAdmin() and !table.IsEmpty(MediaPlayer.Blacklist)) then

		if (args[1] == nil) then return end
		if (tonumber(args[1]) != nil) then return end
		if (MediaPlayer.Blacklist[args[1]] == nil) then return end

		MediaPlayer.Blacklist[args[1]] = nil
		MediaPlayer.SendBlacklist(ply)
	end
end)

--[[
Likes a current video
--]]

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

			if (MediaPlayer.IsSettingTrue("media_announce_likes")) then
				v:SendMessage( ply:GetName() .. " has liked this video!")
			end
		end

		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.GetNewCooldown("Interaction") )

		if (!MediaPlayer.IsSettingTrue("media_announce_dislikes")) then
			ply:SendMessage("Video liked!")
		end


		ply:SetNWBool("MediaPlayer.Engaged", true )
	end
end)

--[[
Dislikes a current video
--]]

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

			if (MediaPlayer.IsSettingTrue("media_announce_dislikes")) then
				v:SendMessage( ply:GetName() .. " has disliked this video!")
			end
		end

		MediaPlayer.AddPlayerCooldown( ply, MediaPlayer.GetNewCooldown("Interaction") )

		if (!MediaPlayer.IsSettingTrue("media_announce_dislikes")) then
			ply:SendMessage("Video disliked!")
		end

		ply:SetNWBool("MediaPlayer.Engaged", true )
	end
end)

--[[
Plays a video
TODO: Move some of this code, support multiple types
--]]

concommand.Add("media_play", function (ply, cmd, args)

	if (!args[1]) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end

	if (MediaPlayer.IsSettingTrue("media_admin_only") and !ply:IsAdmin()) then
		ply:SendMessage("Only admins can use this feature. Sorry.")
		return
	end

	local vids = ply:GetVideos()
	local _c = table.Count(vids)
	local setting = MediaPlayer.GetSetting("player_playlist_max")

	if (_c >= setting.Value and (!ply:IsAdmin() or !MediaPlayer.IsSettingTrue("media_admin_ignore_limits") ) ) then
		ply:SendMessage("You are allowed a maximum of " .. setting.Value .. " in the playlist. You have " .. _c  .. "." )
		return
	end

	if (MediaPlayer.Playlist[args[1]]) then
		ply:SendMessage("This video is already in the playlist!")
		return
	end

	if (MediaPlayer.Blacklist[args[1]]) then
		ply:SendMessage("This video is banned!")
		return
	end

	if (MediaPlayer.HasCooldown(ply, "Play")) then
		ply:SendMessage("Wait a bit before playing something else!")
		return
	end

	local video = MediaPlayer.GetNewVideo()
	video.Video = args[1]
	video.Owner = ply
	video.Position =  MediaPlayer.Count or 0
	video.StartTime = CurTime()

	MediaPlayer.GetYoutubeVideo(video, function(_video)

		if ( _video.Duration <= 0 ) then
			video.Owner:SendMessage("There was something wrong with that video! Please try another one")
			return
		end

		MediaPlayer.AddVideo(video.Video, video)
		MediaPlayer.AddPlayerCooldown(video.Owner, MediaPlayer.GetNewCooldown("Play"))
		ply:SendMessage("Video added!")
		MediaPlayer.Begin(video)
	end)
end)

--[[
Removes a video but doesn't check if its the players
--]]

concommand.Add("media_delete", function(ply, cmd, args)
	if (!args[1]) then return end
	if (!ply:IsAdmin()) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (!table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == args[1]) then return end

	MediaPlayer.RemoveVideo(args[1])

	if (MediaPlayer.IsSettingTrue("media_admin_only")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Video deleted by admin (" .. ply:GetName() .. ")")
		end
	end

	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("media_playlist_limit").Value)
end)

--[[
Removes a video but checks if its the players
--]]

concommand.Add("media_remove", function(ply, cmd, args)
	if (!args[1]) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (!table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == args[1]) then return end

	ply:RemoveVideo(args[1])
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("media_playlist_limit").Value)
end)

--[[
Removes all your videos
--]]

concommand.Add("media_remove_all", function(ply, cmd, args)
	ply:RemoveVideos()
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("media_playlist_limit").Value)
end)
