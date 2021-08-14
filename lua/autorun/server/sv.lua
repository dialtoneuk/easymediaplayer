--[[
	Net Receives
	---------------------------------------------------------------------------
--]]

util.AddNetworkString("MEDIA.SendPlaylist")
util.AddNetworkString("MEDIA.SendCurrentVideo")
util.AddNetworkString("MEDIA.RequestAdminSettings")
util.AddNetworkString("MEDIA.SendAdminSettings")
util.AddNetworkString("MEDIA.SetAdminSettings")
util.AddNetworkString("MEDIA.SearchQuery")
util.AddNetworkString("MEDIA.SendSearchResults")
util.AddNetworkString("MEDIA.SendHistory")
util.AddNetworkString("MEDIA.SendHistoryForVideo")
util.AddNetworkString("MEDIA.RequestHistory")
util.AddNetworkString("MEDIA.SendHistoryData")
util.AddNetworkString("MEDIA.End")
util.AddNetworkString("MEDIA.NewVote")
util.AddNetworkString("MEDIA.EndVote")
util.AddNetworkString("MEDIA.SendMessage")
util.AddNetworkString("MEDIA.SendPersonalHistory")
util.AddNetworkString("MEDIA.SendBlacklist")

--responds to a search query
net.Receive("MEDIA.SearchQuery",function(len, ply)

	if (MEDIA.HasCooldown(ply, "Search")) then return end

	local query = net.ReadString()
	local setting = MEDIA.GetSetting("media_max_results") or {Value = 10}

	MEDIA.AddPlayerCooldown( ply, MEDIA.GetNewCooldown("Search") )

	MEDIA.RequestYoutubeSearch(query, function(data)
		local results = {}

		for k,v in pairs(data) do
			results[v.id.videoId] = {
				Video = v.id.videoId,
				Title = v.snippet.title,
				Creator = v.snippet.channelTitle,
				Thumbnail = v.snippet.thumbnails.default.url,
			}
		end

		net.Start("MEDIA.SendSearchResults")
		net.WriteTable(results)
		net.Send(ply)
	end, setting.Value)
end)

--[[
Sends the servers settings to the client if they are an admin
--]]

net.Receive("MEDIA.RequestAdminSettings",function(len, ply)
	ply:SendAdminSettings()
end)

--[[
Sets settings from the player
--]]

net.Receive("MEDIA.SetAdminSettings",function(len, ply)
	if (!ply:IsAdmin()) then return end

	local tab = net.ReadTable()

	for k,v in pairs(tab) do

		if (MEDIA.Settings[k] == nil ) then
			error("player with the steam id of " .. ply:SteamID() .. " has tried to add settings")
		end

		MEDIA.Settings[k] = v
	end

	MEDIA.SetConvars()
end)

--[[

	HOOKS!

	This loads stuff which requries our settings to be loaded first
	---------------------------------------------------------------
--]]

hook.Add("MEDIA.SettingsPostLoad","MEDIA.MiscStuffLoad", function()

	--loads custom tips from settings
	MEDIA.LoadCustomTips()
	MEDIA.LoadHistory()
	MEDIA.LoadBlacklist()
	MEDIA.CooldownLoop()

	if ( MEDIA.GetSetting("media_tips_enabled").Value == 1) then
		MEDIA.DisplayTip()
	end
end)

--[[
	Chat Commands Hook
	---------------------------------------------------------------------------
--]]

hook.Add("PlayerSay", "MEDIA.PlayerSay", function(ply, msg, teamchat)
	msg = string.lower(msg)
	if ( MEDIA.ParseCommand( ply, msg ) == false ) then
		return msg
	else
		return ""
	end
end)

--[[
	Do our initial spawn on dat client boy
	---------------------------------------------------------------------------
--]]

hook.Add("PlayerInitialSpawn","MEDIA.InitialSpawn",function(ply, transition)
	ply:DoInitialSpawn()
end)

--[[
	Chat Commands can be loaded as soon as the file has been read
	See sv_media_chatcommands.lua
	---------------------------------------------------------------------------
--]]

hook.Add("MEDIA.LoadedChatCommands", "MEDIA.LoadedChatCommands", function()
	MEDIA.LoadChatCommands()
end)

--[[
	Cooldowns can be loaded as soon as the file has been read
	See sv_media_cooldown.lua
	---------------------------------------------------------------------------
--]]

hook.Add("MEDIA.CooldownLoaded","MEDIA.LoadCooldowns", function()
	MEDIA.LoadCooldowns()
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

hook.Add("MEDIA.VotingLoaded", "MEDIA.VotingLoaded", function()
	MEDIA.LoadVotes()
end)

--[[
Console command to vote
--]]

concommand.Add("media_start_vote", function(ply, cmd, args)
	if (MEDIA.HasCooldown(ply, "Vote")) then
		ply:SendMessage("You have started a vote too recently!")
		return
	end

	--if there is no current vote
	if (!table.IsEmpty(MEDIA.CurrentVideo)) then
		if ( args[1] == nil or args[1] == "") then return end

		--if this vote doesn't exist
		if (!MEDIA.Votes[args[1]]) then return end
		if (MEDIA.HasCurrentVote()) then return end

		--add a cooldown to the activator so they can't spam vote
		MEDIA.AddPlayerCooldown( ply, MEDIA.GetNewCooldown("Vote") )

		--start the vote
		MEDIA.StartVote(args[1], ply )
	end
end)


--[[
	Various Console commands
---------------------------------------------------------------------------
--]]

concommand.Add("media_reload_cooldowns", function(ply)
	if (!ply:IsAdmin()) then return end

	MEDIA.LoadCooldowns()
end)

concommand.Add("media_reload_chat_commands", function(ply)
	if (!ply:IsAdmin()) then return end

	MEDIA.LoadChatCommands()
end)


concommand.Add("media_reload_blacklist", function(ply)
	if (!ply:IsAdmin()) then return end

	MEDIA.SendBlacklist(ply)
end)

--[[
Requests personal history from the server
--]]

concommand.Add("media_request_personal_history", function(ply, cmd, args)
	if (!args[1]) then return end
	if (MEDIA.HasCooldown(ply, "History")) then return end

	local page = math.abs(tonumber(args[1]) - 1)
	local setting = MEDIA.GetSetting("media_history_max") or { Value = 10 }

	local data = ply:GetPersonalHistory(setting.Value, page * setting.Value )

	if (data == nil or table.IsEmpty(data)) then return end

	MEDIA.SendPersonalHistoryData(ply, data)
	MEDIA.AddPlayerCooldown(ply, MEDIA.GetNewCooldown("History"))
end)

--[[
Requests history from the server
--]]

concommand.Add("media_request_history", function(ply, cmd, args)
	if (!args[1]) then return end
	if (MEDIA.HasCooldown(ply, "History")) then return end

	local page = math.abs(tonumber(args[1]) - 1)
	local setting = MEDIA.GetSetting("media_history_max") or { Value = 10}
	local results = {}

	if (table.IsEmpty(MEDIA.History)) then return end

	if (table.Count(MEDIA.History) < ( page * setting.Value) ) then
		results = {}
	else
		local count = 0
		local start = ( page * setting.Value )
		local finish = start + setting.Value
		results = {}

		for k,v in SortedPairsByMemberValue(MEDIA.History, "LastPlayed", true ) do


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
		MEDIA.SendHistoryData(ply, results)
		MEDIA.AddPlayerCooldown(ply, MEDIA.GetNewCooldown("History"))
	end
end)

--[[
Command to refresh settings
--]]

concommand.Add("media_refresh_settings", function(ply)
	ply:SendAdminSettings()
end)

--[[
Reloads the playlist Playlist
--]]

concommand.Add("media_reload_playlist",function(ply)
	if (!ply:IsAdmin()) then return end

	MEDIA.BroadcastPlaylist()
end)

--[[
Skips a video
--]]

concommand.Add("media_skip_video", function(ply)
	if (ply:IsAdmin() and !table.IsEmpty(MEDIA.CurrentVideo)) then
		MEDIA.SkipVideo()

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
		if (args[1] == nil and table.IsEmpty(MEDIA.CurrentVideo)) then return end

		local video

		if (args[1] != nil ) then video = MEDIA.GetVideo(args[1]) else video = MEDIA.CurrentVideo end
		if (video == nil or table.IsEmpty(video)) then return end

		MEDIA.AddToBlacklist(video, ply )

		if (MEDIA.CurrentVideo.Video == video.Video) then
			MEDIA.SkipVideo()
		else
			MEDIA.RemoveVideo(video.Video)
			MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
		end

		if (MEDIA.GetSetting("media_announce_admin").Value == 1 ) then
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
	if (ply:IsAdmin() and !table.IsEmpty(MEDIA.Blacklist)) then

		if (args[1] == nil) then return end
		if (tonumber(args[1]) != nil) then return end
		if (MEDIA.Blacklist[args[1]] == nil) then return end

		MEDIA.Blacklist[args[1]] = nil
		MEDIA.SendBlacklist(ply)
	end
end)

--[[
Likes a current video
--]]

concommand.Add("media_like_video", function(ply, cmd, args)
	if (MEDIA.HasCooldown(ply, "Interaction")) then ply:SendMessage("You have liked a video too recently") return end
	if (args[1] == nil and table.IsEmpty(MEDIA.CurrentVideo)) then return end

	local video

	if (args[1] != nil ) then video = MEDIA.GetVideo(args[1]) else video = MEDIA.CurrentVideo end

	if (video) then
		MEDIA.LikeVideo(video)
		MEDIA.SendHistoryForVideo(ply, MEDIA.History[video.Video])
		MEDIA.AddPlayerCooldown( ply, MEDIA.GetNewCooldown("Interaction") )
		ply:SendMessage("Video liked!")
	end
end)

--[[
Dislikes a current video
--]]

concommand.Add("media_dislike_video", function(ply, cmd, args)
	if (MEDIA.HasCooldown(ply, "Interaction")) then ply:SendMessage("You have disliked a video too recently") return end
	if (args[1] == nil and table.IsEmpty(MEDIA.CurrentVideo)) then return end

	local video
	if (args[1] != nil ) then video = MEDIA.GetVideo(args[1]) else video = MEDIA.CurrentVideo end

	if (video) then
		MEDIA.DislikeVideo(video)
		MEDIA.SendHistoryForVideo(ply, MEDIA.History[video.Video])
		MEDIA.AddPlayerCooldown( ply, MEDIA.GetNewCooldown("Interaction") )
		ply:SendMessage("Video disliked!")
	end
end)

--[[
Plays a video
--]]

concommand.Add("media_play", function (ply, cmd, args)

	if (!args[1]) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end

	if (MEDIA.GetSetting("media_admin_only").Value == 1 and !ply:IsAdmin()) then
		ply:SendMessage("Only admins can use this feature. Sorry.")
		return
	end

	local vids = ply:GetVideos()
	local _c = table.Count(vids)
	local setting = MEDIA.GetSetting("player_playlist_max")
	local ignore_limit = MEDIA.GetSetting("admins_ignore_playlist_limit")

	if (vids != nil and !table.IsEmpty(vids) and _c >= setting.Value and (!ply:IsAdmin() or !ignore_limit.Value ) ) then
		ply:SendMessage("You are allowed a maximum of " .. setting.Value .. " in the playlist. You have " .. _c  .. "." )
		return
	end

	if (MEDIA.Playlist[args[1]]) then
		ply:SendMessage("This video is already in the playlist!")
		return
	end

	if (MEDIA.Blacklist[args[1]]) then
		ply:SendMessage("This video is banned!")
		return
	end

	if (MEDIA.HasCooldown(ply, "Play")) then
		ply:SendMessage("Wait a bit before playing something else!")
		return
	end

	local video = MEDIA.GetNewVideo()
	video.Video = args[1]
	video.Owner = ply
	video.Position =  MEDIA.Count or 0
	video.StartTime = CurTime()

	MEDIA.GetYoutubeVideo(video, function(_video)

		if ( _video.Duration <= 0 ) then
			video.Owner:SendMessage("There was something wrong with that video! Please try another one")
			return
		end

		MEDIA.AddVideo(video.Video, video)
		MEDIA.AddPlayerCooldown(video.Owner, MEDIA.GetNewCooldown("Play"))
		ply:SendMessage("Video added!")
		MEDIA.Begin(video)
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
	if (!table.IsEmpty(MEDIA.CurrentVideo) and MEDIA.CurrentVideo.Video == args[1]) then return end

	MEDIA.RemoveVideo(args[1])

	if (MEDIA.GetSetting("media_announce_admin").Value == 1 ) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Video deleted by admin (" .. ply:GetName() .. ")")
		end
	end

	MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
end)

--[[
Removes a video but checks if its the players
--]]

concommand.Add("media_remove", function(ply, cmd, args)
	if (!args[1]) then return end
	if (tonumber(args[1]) != nil) then return end
	if (string.len(args[1]) > 32) then return end
	if (!table.IsEmpty(MEDIA.CurrentVideo) and MEDIA.CurrentVideo.Video == args[1]) then return end

	ply:RemoveVideo(args[1])
	MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
end)

--[[
Removes all your videos
--]]

concommand.Add("media_remove_all", function(ply, cmd, args)
	ply:RemoveVideos()
	MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
end)
