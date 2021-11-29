--This is what actually start the playlist and what is called to begin,
--if its the fisrt video it'll instantly play it, if not it'll go around in this callback loop until no videos are left
function LydsPlayer.Begin(video)

	if (type(video) != "table") then error("must be a table") end

	if (table.IsEmpty(LydsPlayer.CurrentVideo)) then
		LydsPlayer.StartVideo(video, function()
			LydsPlayer.AddToSession(video)
			LydsPlayer.RemoveVideo(video.Video)
			LydsPlayer.StopVideo(video.Video)

			if (LydsPlayer.HasNext()) then
				--Next please
				LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
				LydsPlayer.Begin(LydsPlayer.Next())
			else
				--Ending
				LydsPlayer.Playlist = {}
				LydsPlayer.CurrentVideo = {}
				LydsPlayer.BroadcastEnd()
			end
		end)
	else
		LydsPlayer.AnnouncePlaylistAddition(video)
		LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
	end
end

--announces a new video
function LydsPlayer.AnnounceVideo()
	if (!LydsPlayer.CurrentVideo or table.IsEmpty(LydsPlayer.CurrentVideo)) then return end
	if (!LydsPlayer.IsSettingTrue("announce_video")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMediaPlayerMessage("Now playing '" .. LydsPlayer.CurrentVideo.Title .. "' submitted by " .. LydsPlayer.CurrentVideo.Owner:GetName())
	end
end

--announces the addition of a new video into the playlist
function LydsPlayer.AnnouncePlaylistAddition(video)
	if (!video or table.IsEmpty(video)) then return end
	if (!LydsPlayer.IsSettingTrue("announce_addition")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMediaPlayerMessage("Added '" .. video.Title .. "' submitted by " .. video.Owner:GetName())
	end
end

--announces the ending of the video
function LydsPlayer.AnnounceVideoEnding(video)
	if (!video or table.IsEmpty(video)) then return end
	if (!LydsPlayer.IsSettingTrue("announce_ending")) then return end

	for k,v in pairs(player.GetAll()) do
		v:SendMediaPlayerMessage("Video '" .. video.Title .. "' over!")
	end
end

--sends the session data
function LydsPlayer.SendSessionChunk(ply, data)
	if (table.IsEmpty(LydsPlayer.Session)) then return end

	net.Start("LydsPlayer.SendSessionChunk")
		net.WriteTable(data)
	net.Send(ply)
end

--sends all the videos the user has played this session
function LydsPlayer.SendPersonalSessionData(ply, data)
	if (table.IsEmpty(LydsPlayer.Session)) then return end

	net.Start("LydsPlayer.SendPersonalSession")
		net.WriteTable(data)
	net.Send(ply)
end

--sends all of the history to the player
function LydsPlayer.SendSession(ply)
	if (table.IsEmpty(LydsPlayer.Session)) then return end

	net.Start("LydsPlayer.SendSession")
		net.WriteTable(LydsPlayer.Session)
	net.Send(ply)
end

--sends the history just for that video
function LydsPlayer.SendSessionForVideo(ply, video)
	net.Start("LydsPlayer.SendSessionForVideo")
		net.WriteTable(video)
	net.Send(ply)
end

--sends all of the banned videos to a player if they are an admin
function LydsPlayer.SendBlacklist(ply)
	if (!ply:IsAdmin()) then return end
	if (table.IsEmpty(LydsPlayer.Blacklist)) then return end

	net.Start("LydsPlayer.SendBlacklist")
		net.WriteTable(LydsPlayer.Blacklist)
	net.Send(ply)
end

--sends a section of the playlist to the player, limit is set in admin settings under playist_max_limit
function LydsPlayer.SendPlaylistSection(ply, limit)
	net.Start("LydsPlayer.SendPlaylist")
		net.WriteTable(LydsPlayer.GetVideos(false, limit))
	net.Send(ply)
end

--broadcasts a section of the playlist to all players
function LydsPlayer.BroadcastSection(limit)
	for k,v in pairs(player.GetAll()) do
		LydsPlayer.SendPlaylistSection(v, limit )
	end
end

--broadcasts the end of a video to all players
function LydsPlayer.BroadcastEnd()
	for k,v in pairs(player.GetAll()) do
		LydsPlayer.SendEnd(v)
	end
end

--sends the entire playlist to player
function LydsPlayer.SendPlaylist(ply)
	net.Start("LydsPlayer.SendPlaylist")
	net.WriteTable(LydsPlayer.GetVideos(false))
	net.Send(ply)
end

--tells a player that the video has ended
function LydsPlayer.SendEnd(ply)
	net.Start("LydsPlayer.End")
	net.Send(ply)
end

--broadcasts th plailist to ever
function LydsPlayer.BroadcastPlaylist()
	for k,v in pairs(player.GetAll()) do
		LydsPlayer.SendPlaylist(v)
	end
end

--starts a new video
function LydsPlayer.StartVideo(video, callback)
	LydsPlayer.CurrentVideo = video
	LydsPlayer.BroadcastCurrentVideo()
	LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
	LydsPlayer.AnnounceVideo()

	--for our voting
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("LydsPlayer.Engaged", false )
	end

	timer.Create("LydsPlayer.VideoTimer", video.Duration, 1, function()
		LydsPlayer.StopVideo()
		callback()
	end)
end

--skips a video
function LydsPlayer.SkipVideo()

	local video = LydsPlayer.CurrentVideo
	LydsPlayer.AddToSession(video)
	LydsPlayer.RemoveVideo(video.Video)
	LydsPlayer.StopVideo(video.Video)

	if (LydsPlayer.HasNext()) then
		--Next please
		LydsPlayer.BroadcastSection(LydsPlayer.GetSetting("playlist_broadcast_limit").Value)
		LydsPlayer.Begin(LydsPlayer.Next())
	else
		--Ending
		LydsPlayer.Playlist = {}
		LydsPlayer.CurrentVideo = {}
		LydsPlayer.BroadcastEnd()
	end
end

--[[
	Stops the current video
--]]

function LydsPlayer.StopVideo()
	if (timer.Exists("LydsPlayer.VideoTimer")) then timer.Remove("LydsPlayer.VideoTimer") end


	LydsPlayer.AnnounceVideoEnding(LydsPlayer.CurrentVideo)

	LydsPlayer.CurrentVideo = {}
end

--[[
	Broadcasts the current video to the players
--]]

function LydsPlayer.BroadcastCurrentVideo()
	for k,v in pairs(player.GetAll()) do
		net.Start("LydsPlayer.SendCurrentVideo")
		net.WriteTable(LydsPlayer.CurrentVideo or {})
		net.Send(v)
	end
end
