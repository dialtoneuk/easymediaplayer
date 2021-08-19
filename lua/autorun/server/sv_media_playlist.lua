--playlist global
MediaPlayer.Playlist = MediaPlayer.Playlist or {}
MediaPlayer.CurrentVideo = MediaPlayer.CurrentVideo or {}
MediaPlayer.Count = MediaPlayer.Count or 0

--types of videos
MediaPlayer.MediaPlayerType = MediaPlayer.MediaPlayerType or {
	YOUTUBE = "youtube",
	DAILYMOTION = "dailymotion",
	SOUNDCLOUD = "soundcloud"
}

--Copy table
MediaPlayer.BaseVideo = {
	Video = "38enrQGRDhA",
	Title = "Default",
	Creator = "Default",
	Views = 1,
	Type = MediaPlayer.MediaPlayerType.YOUTUBE,
	Duration = 1,
	Position = 1,
	StartTime = 0, --Used for time tracking
	Player = {}, --this should be an array of the different kinds of quality of embeds
	Owner = {} --this will be a player entity on the servers end and a table on the clients end
}

--[[
Gets a number of videos
--]]

function MediaPlayer.GetVideos(owner, limit)
	local results = {}
	local max = limit or 1000

	for k,v in SortedPairsByMemberValue(MediaPlayer.Playlist, "Position") do
		if (max > 0) then
			local copy = table.Copy(v)
			if (!owner) then
				local tab = {
					Name = v.Owner:GetName(),
					SteamID = v.Owner:SteamID(),
					SteamIDLong = v.Owner:SteamID64()
				}

				copy.Owner = tab
			end

			results[k] = copy

			if (limit) then
				max = max - 1
			end
		else
			break
		end
	end

	return results
end

--[[
Return true if we have next
--]]

function MediaPlayer.HasNext()
	return !table.IsEmpty(MediaPlayer.Playlist)
end

--[[
Broadcast's the next video to the player
--]]

function MediaPlayer.Next()
	if (!MediaPlayer.HasNext() ) then return end

	for k,v in SortedPairsByMemberValue(MediaPlayer.Playlist, "Position") do
		return v
	end
end

--[[
Copys a new video table
--]]

function MediaPlayer.GetNewVideo()
	return table.Copy(MediaPlayer.BaseVideo)
end

--[[
Clears the playlist
--]]

function MediaPlayer.ClearPlaylist(ply)

	if (!ply:IsAdmin()) then return end

	MediaPlayer.Playlist = {}
	MediaPlayer.Count = 0
end

--[[
Adds a video to the playlist
--]]

function MediaPlayer.AddVideo(video, tab)
	if (MediaPlayer.Playlist[video]) then return end --already exists

	MediaPlayer.Playlist[video] = tab
	MediaPlayer.Count = MediaPlayer.Count + 1
end

--[[
Removes a video to the playlist
--]]

function MediaPlayer.RemoveVideo(video)
	if (MediaPlayer.Playlist[video] == nil) then return end --does not exist??

	MediaPlayer.Playlist[video] = nil
end

--[[`
Gets a video
--]]

function MediaPlayer.GetVideo(video)
	if (!MediaPlayer.Playlist[video]) then return nil end

	return MediaPlayer.Playlist[video]
end
