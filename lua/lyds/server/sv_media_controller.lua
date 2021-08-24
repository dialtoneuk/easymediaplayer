--This is what actually start the playlist and what is called to begin,
--if its the fisrt video it'll instantly play it, if not it'll go around in this callback loop until no videos are left
function MediaPlayer.Begin(video)

	if (type(video) != "table") then error("must be a table") end

	if (table.IsEmpty(MediaPlayer.CurrentVideo)) then
		MediaPlayer.StartVideo(video, function()
			MediaPlayer.AddToHistory(video)
			MediaPlayer.RemoveVideo(video.Video)
			MediaPlayer.StopVideo(video.Video)

			if (MediaPlayer.HasNext()) then
				--Next please
				MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
				MediaPlayer.Begin(MediaPlayer.Next())
			else
				--Ending
				MediaPlayer.Playlist = {}
				MediaPlayer.CurrentVideo = {}
				MediaPlayer.BroadcastEnd()
			end
		end)
	else
		MediaPlayer.AnnouncePlaylistAddition(video)
		MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
	end
end

--announces a new video
function MediaPlayer.AnnounceVideo()
	if (!MediaPlayer.CurrentVideo or table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	if (!MediaPlayer.IsSettingTrue("announce_video")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Now playing '" .. MediaPlayer.CurrentVideo.Title .. "' submitted by " .. MediaPlayer.CurrentVideo.Owner:GetName())
	end
end

--announces the addition of a new video into the playlist
function MediaPlayer.AnnouncePlaylistAddition(video)
	if (!video or table.IsEmpty(video)) then return end
	if (!MediaPlayer.IsSettingTrue("announce_addition")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Added '" .. video.Title .. "' submitted by " .. video.Owner:GetName())
	end
end

--announces the ending of the video
function MediaPlayer.AnnounceVideoEnding(video)
	if (!video or table.IsEmpty(video)) then return end
	if (!MediaPlayer.IsSettingTrue("announce_ending")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Video '" .. video.Title .. "' over!")
	end
end

--sends server history items to the player
function MediaPlayer.SendHistoryData(ply, data)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendHistoryData")
		net.WriteTable(data)
		net.WriteFloat(table.Count( MediaPlayer.History ))
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--sends the personal history of a player to them selves
function MediaPlayer.SendPersonalHistoryData(ply, data)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendPersonalHistory")
		net.WriteTable(data)
		net.WriteFloat( ply:GetPersonalHistoryCount() )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--sends all of the history to the player
function MediaPlayer.SendHistory(ply)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendHistory")
		net.WriteTable(MediaPlayer.History)
		net.WriteFloat( table.Count( MediaPlayer.History ) )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--sends the history just for that video
function MediaPlayer.SendHistoryForVideo(ply, video)
	net.Start("MediaPlayer.SendHistoryForVideo")
		net.WriteTable(video)
	net.Send(ply)
end

--sends all of the banned videos to a player if they are an admin
function MediaPlayer.SendBlacklist(ply)
	if (!ply:IsAdmin()) then return end
	if (table.IsEmpty(MediaPlayer.Blacklist)) then return end

	net.Start("MediaPlayer.SendBlacklist")
		net.WriteTable(MediaPlayer.Blacklist)
	net.Send(ply)
end

--sends a section of the playlist to the player, limit is set in admin settings under playist_max_limit
function MediaPlayer.SendPlaylistSection(ply, limit)
	net.Start("MediaPlayer.SendPlaylist")
		net.WriteTable(MediaPlayer.GetVideos(false, limit))
	net.Send(ply)
end

--broadcasts a section of the playlist to all players
function MediaPlayer.BroadcastSection(limit)
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendPlaylistSection(v, limit )
	end
end

--broadcasts the end of a video to all players
function MediaPlayer.BroadcastEnd()
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendEnd(v)
	end
end

--sends the entire playlist to player
function MediaPlayer.SendPlaylist(ply)
	net.Start("MediaPlayer.SendPlaylist")
	net.WriteTable(MediaPlayer.GetVideos(false))
	net.Send(ply)
end

--tells a player that the video has ended
function MediaPlayer.SendEnd(ply)
	net.Start("MediaPlayer.End")
	net.Send(ply)
end

--broadcasts th plailist to ever
function MediaPlayer.BroadcastPlaylist()
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendPlaylist(v)
	end
end

--starts a new video
function MediaPlayer.StartVideo(video, callback)
	MediaPlayer.CurrentVideo = video
	MediaPlayer.BroadcastCurrentVideo()
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
	MediaPlayer.AnnounceVideo()

	--for our voting
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("MediaPlayer.Engaged", false )
	end

	timer.Create("MediaPlayer.VideoTimer", video.Duration, 1, function()
		MediaPlayer.StopVideo()
		callback()
	end)
end

--skips a video
function MediaPlayer.SkipVideo()

	local video = MediaPlayer.CurrentVideo
	MediaPlayer.AddToHistory(video)
	MediaPlayer.RemoveVideo(video.Video)
	MediaPlayer.StopVideo(video.Video)

	if (MediaPlayer.HasNext()) then
		--Next please
		MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("playlist_broadcast_limit").Value)
		MediaPlayer.Begin(MediaPlayer.Next())
	else
		--Ending
		MediaPlayer.Playlist = {}
		MediaPlayer.CurrentVideo = {}
		MediaPlayer.BroadcastEnd()
	end
end

--[[
	Stops the current video
--]]

function MediaPlayer.StopVideo()
	if (timer.Exists("MediaPlayer.VideoTimer")) then timer.Remove("MediaPlayer.VideoTimer") end


	MediaPlayer.AnnounceVideoEnding(MediaPlayer.CurrentVideo)

	MediaPlayer.CurrentVideo = {}
end

--[[
	Broadcasts the current video to the players
--]]

function MediaPlayer.BroadcastCurrentVideo()
	for k,v in pairs(player.GetAll()) do
		net.Start("MediaPlayer.SendCurrentVideo")
		net.WriteTable(MediaPlayer.CurrentVideo or {})
		net.Send(v)
	end
end
