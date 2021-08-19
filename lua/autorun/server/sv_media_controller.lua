--[[
	Announces a new video
--]]

function MediaPlayer.AnnounceVideo()
	if (!MediaPlayer.CurrentVideo or table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Now playing [" .. MediaPlayer.CurrentVideo.Title .. "] submitted by " .. MediaPlayer.CurrentVideo.Owner:GetName())
	end
end

--[[
	Announces an addition to the playlist
--]]

function MediaPlayer.AnnouncePlaylistAddition(video)
	if (!video or table.IsEmpty(video)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Added [" .. video.Title .. "] submitted by " .. video.Owner:GetName())
	end
end

--[[
	Announces an ending to a video
--]]

function MediaPlayer.AnnounceVideoEnding(video)
	if (!video or table.IsEmpty(video)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Video [" .. video.Title .. "] over!")
	end
end


--[[
	Send Data to player
--]]

function MediaPlayer.SendHistoryData(ply, data)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("MediaPlayer_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendHistoryData")
		net.WriteTable(data)
		net.WriteFloat(table.Count( MediaPlayer.History ))
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--[[
	Send Data to player
--]]

function MediaPlayer.SendPersonalHistoryData(ply, data)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("MediaPlayer_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendPersonalHistory")
		net.WriteTable(data)
		net.WriteFloat( ply:GetPersonalHistoryCount() )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--[[
Send All History to player
--]]

function MediaPlayer.SendHistory(ply)
	if (table.IsEmpty(MediaPlayer.History)) then return end
	local setting = MediaPlayer.GetSetting("MediaPlayer_history_max") or { Value = 25 }

	net.Start("MediaPlayer.SendHistory")
		net.WriteTable(MediaPlayer.History)
		net.WriteFloat( table.Count( MediaPlayer.History ) )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end



function MediaPlayer.SendHistoryForVideo(ply, video)
	net.Start("MediaPlayer.SendHistoryForVideo")
		net.WriteTable(video)
	net.Send(ply)
end

--[[
Send blacklist to player
--]]

function MediaPlayer.SendBlacklist(ply)
	if (table.IsEmpty(MediaPlayer.Blacklist)) then return end

	net.Start("MediaPlayer.SendBlacklist")
		net.WriteTable(MediaPlayer.Blacklist)
	net.Send(ply)
end

--[[
Sends a section of the playlist
--]]

function MediaPlayer.SendPlaylistSection(ply, limit)
	net.Start("MediaPlayer.SendPlaylist")
		net.WriteTable(MediaPlayer.GetVideos(false, limit))
	net.Send(ply)
end

--[[
Broadcast a selection
--]]

function MediaPlayer.BroadcastSection(limit)
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendPlaylistSection(v, limit )
	end
end

--[[
	Broadcasts end to all players
--]]

function MediaPlayer.BroadcastEnd()
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendEnd(v)
	end
end

--[[
	Sends the entire playlist
--]]

function MediaPlayer.SendPlaylist(ply)
	net.Start("MediaPlayer.SendPlaylist")
	net.WriteTable(MediaPlayer.GetVideos(false))
	net.Send(ply)
end

--[[
	Tells a player the playlist has ended / no next current video
--]]

function MediaPlayer.SendEnd(ply)
	net.Start("MediaPlayer.End")
	net.Send(ply)
end

--[[
	Broadcast the entire playlist
--]]

function MediaPlayer.BroadcastPlaylist()
	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendPlaylistSection(v)
	end
end

--[[
	Starts a new video
--]]

function MediaPlayer.StartVideo(video, callback)
	MediaPlayer.CurrentVideo = video
	MediaPlayer.BroadcastCurrentVideo()
	MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("MediaPlayer_playlist_limit").Value)

	if (MediaPlayer.GetSetting("MediaPlayer_announce_video").Value) then
		MediaPlayer.AnnounceVideo()
	end

	timer.Create("MediaPlayer.VideoTimer", video.Duration, 1, function()
		MediaPlayer.StopVideo()
		callback()
	end)
end

--[[
	Skips a video
--]]

function MediaPlayer.SkipVideo()

	local video = MediaPlayer.CurrentVideo
	MediaPlayer.AddToHistory(video)
	MediaPlayer.RemoveVideo(video.Video)
	MediaPlayer.StopVideo(video.Video)

	if (MediaPlayer.HasNext()) then
		--Next please
		MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("MediaPlayer_playlist_limit").Value)
		MediaPlayer.Begin(MediaPlayer.Next())
	else
		--Ending
		MediaPlayer.Playlist = {}
		MediaPlayer.CurrentVideo = {}
		MediaPlayer.BroadcastEnd()
	end
end

--[[
	Calls when a new MediaPlayer video is added. Begins the playlist or broadcasts the current playlist
--]]

function MediaPlayer.Begin(video)
	if (table.IsEmpty(MediaPlayer.CurrentVideo)) then
		MediaPlayer.StartVideo(video, function()
			MediaPlayer.AddToHistory(video)
			MediaPlayer.RemoveVideo(video.Video)
			MediaPlayer.StopVideo(video.Video)

			if (MediaPlayer.HasNext()) then
				--Next please
				MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("MediaPlayer_playlist_limit").Value)
				MediaPlayer.Begin(MediaPlayer.Next())
			else
				--Ending
				MediaPlayer.Playlist = {}
				MediaPlayer.CurrentVideo = {}
				MediaPlayer.BroadcastEnd()
			end
		end)
	else
		if (MediaPlayer.GetSetting("MediaPlayer_announce_addition").Value) then
			MediaPlayer.AnnouncePlaylistAddition(video)
		end

		MediaPlayer.BroadcastSection(MediaPlayer.GetSetting("MediaPlayer_playlist_limit").Value)
	end
end

--[[
	Stops the current video
--]]

function MediaPlayer.StopVideo()
	if (timer.Exists("MediaPlayer.VideoTimer")) then timer.Remove("MediaPlayer.VideoTimer") end

	if (MediaPlayer.GetSetting("MediaPlayer_announce_ending").Value) then
		MediaPlayer.AnnounceVideoEnding(MediaPlayer.CurrentVideo)
	end

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
