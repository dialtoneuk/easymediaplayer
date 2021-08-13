--[[
	Announces a new video
--]]

function MEDIA.AnnounceVideo()
	if (!MEDIA.CurrentVideo or table.IsEmpty(MEDIA.CurrentVideo)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Now playing [" .. MEDIA.CurrentVideo.Title .. "] submitted by " .. MEDIA.CurrentVideo.Owner:GetName())
	end
end

--[[
	Announces an addition to the playlist
--]]

function MEDIA.AnnouncePlaylistAddition(video)
	if (!video or table.IsEmpty(video)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Added [" .. video.Title .. "] submitted by " .. video.Owner:GetName())
	end
end

--[[
	Announces an ending to a video
--]]

function MEDIA.AnnounceVideoEnding(video)
	if (!video or table.IsEmpty(video)) then return end
	for k,v in pairs(player.GetAll()) do
		v:SendMessage("Video [" .. video.Title .. "] over!")
	end
end


--[[
	Send Data to player
--]]

function MEDIA.SendHistoryData(ply, data)
	if (table.IsEmpty(MEDIA.History)) then return end
	local setting = MEDIA.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MEDIA_SendHistoryData")
		net.WriteTable(data)
		net.WriteFloat(table.Count( MEDIA.History ))
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--[[
	Send Data to player
--]]

function MEDIA.SendPersonalHistoryData(ply, data)
	if (table.IsEmpty(MEDIA.History)) then return end
	local setting = MEDIA.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MEDIA_SendPersonalHistory")
		net.WriteTable(data)
		net.WriteFloat( ply:GetPersonalHistoryCount() )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end

--[[
Send All History to player
--]]

function MEDIA.SendHistory(ply)
	if (table.IsEmpty(MEDIA.History)) then return end
	local setting = MEDIA.GetSetting("media_history_max") or { Value = 25 }

	net.Start("MEDIA_SendHistory")
		net.WriteTable(MEDIA.History)
		net.WriteFloat( table.Count( MEDIA.History ) )
		net.WriteFloat(setting.Value)
	net.Send(ply)
end



function MEDIA.SendHistoryForVideo(ply, video)
	net.Start("MEDIA_SendHistoryForVideo")
		net.WriteTable(video)
	net.Send(ply)
end

--[[
Send blacklist to player
--]]

function MEDIA.SendBlacklist(ply)
	if (table.IsEmpty(MEDIA.Blacklist)) then return end

	net.Start("MEDIA_SendBlacklist")
		net.WriteTable(MEDIA.Blacklist)
	net.Send(ply)
end

--[[
Sends a section of the playlist
--]]

function MEDIA.SendPlaylistSection(ply, limit)
	net.Start("MEDIA_SendPlaylist")
		net.WriteTable(MEDIA.GetVideos(false, limit))
	net.Send(ply)
end

--[[
Broadcast a selection
--]]

function MEDIA.BroadcastSection(limit)
	for k,v in pairs(player.GetAll()) do
		MEDIA.SendPlaylistSection(v, limit )
	end
end

--[[
	Broadcasts end to all players
--]]

function MEDIA.BroadcastEnd()
	for k,v in pairs(player.GetAll()) do
		MEDIA.SendEnd(v)
	end
end

--[[
	Sends the entire playlist
--]]

function MEDIA.SendPlaylist(ply)
	net.Start("MEDIA_SendPlaylist")
	net.WriteTable(MEDIA.GetVideos(false))
	net.Send(ply)
end

--[[
	Tells a player the playlist has ended / no next current video
--]]

function MEDIA.SendEnd(ply)
	net.Start("MEDIA_End")
	net.Send(ply)
end

--[[
	Broadcast the entire playlist
--]]

function MEDIA.BroadcastPlaylist()
	for k,v in pairs(player.GetAll()) do
		MEDIA.SendPlaylistSection(v)
	end
end

--[[
	Starts a new video
--]]

function MEDIA.StartVideo(video, callback)
	MEDIA.CurrentVideo = video
	MEDIA.BroadcastCurrentVideo()
	MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)

	if (MEDIA.GetSetting("media_announce_video").Value == 1 ) then
		MEDIA.AnnounceVideo()
	end

	print("starting timer for video: " .. video.Video )
	timer.Create("MEDIA_VideoTimer", video.Duration, 1, function()
		MEDIA.StopVideo()
		callback()
	end)
end

--[[
	Skips a video
--]]

function MEDIA.SkipVideo()

	local video = MEDIA.CurrentVideo
	MEDIA.AddToHistory(video)
	MEDIA.RemoveVideo(video.Video)
	MEDIA.StopVideo(video.Video)

	if (MEDIA.HasNext()) then
		--Next please
		print("beginning next")
		MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
		MEDIA.Begin(MEDIA.Next())
	else
		--Ending
		MEDIA.Playlist = {}
		MEDIA.CurrentVideo = {}
		MEDIA.BroadcastEnd()
		print("no more")
	end
end

--[[
	Calls when a new media video is added. Begins the playlist or broadcasts the current playlist
--]]

function MEDIA.Begin(video)
	if (table.IsEmpty(MEDIA.CurrentVideo)) then
		MEDIA.StartVideo(video, function()
			MEDIA.AddToHistory(video)
			MEDIA.RemoveVideo(video.Video)
			MEDIA.StopVideo(video.Video)

			if (MEDIA.HasNext()) then
				--Next please
				MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
				MEDIA.Begin(MEDIA.Next())
			else
				--Ending
				MEDIA.Playlist = {}
				MEDIA.CurrentVideo = {}
				MEDIA.BroadcastEnd()
			end
		end)
	else
		if (MEDIA.GetSetting("media_announce_addition").Value == 1) then
			MEDIA.AnnouncePlaylistAddition(video)
		end

		MEDIA.BroadcastSection(MEDIA.GetSetting("media_playlist_limit").Value)
	end
end

--[[
	Stops the current video
--]]

function MEDIA.StopVideo()
	if (timer.Exists("MEDIA_VideoTimer")) then timer.Remove("MEDIA_VideoTimer") end

	if (MEDIA.GetSetting("media_announce_ending").Value == 1) then
		MEDIA.AnnounceVideoEnding(MEDIA.CurrentVideo)
	end

	MEDIA.CurrentVideo = {}
end

--[[
	Broadcasts the current video to the players
--]]

function MEDIA.BroadcastCurrentVideo()
	for k,v in pairs(player.GetAll()) do
		net.Start("MEDIA_SendCurrentVideo")
		net.WriteTable(MEDIA.CurrentVideo or {})
		net.Send(v)
	end
end
