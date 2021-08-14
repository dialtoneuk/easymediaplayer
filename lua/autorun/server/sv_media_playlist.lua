--playlist global
MEDIA.Playlist = MEDIA.Playlist or {}
MEDIA.CurrentVideo = MEDIA.CurrentVideo or {}
MEDIA.Count = MEDIA.Count or 0

--types of videos
MEDIA.MediaType = MEDIA.MediaType or {
	YOUTUBE = "youtube",
	DAILYMOTION = "dailymotion",
	SOUNDCLOUD = "soundcloud"
}

--Copy table
MEDIA.BaseVideo = {
	Video = "38enrQGRDhA",
	Title = "Default",
	Creator = "Default",
	Views = 1,
	Type = MEDIA.MediaType.YOUTUBE,
	Duration = 1,
	Position = 1,
	StartTime = 0, --Used for time tracking
	Player = {}, --this should be an array of the different kinds of quality of embeds
	Owner = {} --this will be a player entity on the servers end and a table on the clients end
}

--[[
Gets a number of videos
--]]

function MEDIA.GetVideos(owner, limit)
	local results = {}
	local max = limit or 1000

	for k,v in SortedPairsByMemberValue(MEDIA.Playlist, "Position") do
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

function MEDIA.HasNext()
	return !table.IsEmpty(MEDIA.Playlist)
end

--[[
Broadcast's the next video to the player
--]]

function MEDIA.Next()
	if (!MEDIA.HasNext() ) then return end

	for k,v in SortedPairsByMemberValue(MEDIA.Playlist, "Position") do
		return v
	end
end

--[[
Copys a new video table
--]]

function MEDIA.GetNewVideo()
	return table.Copy(MEDIA.BaseVideo)
end

--[[
Clears the playlist
--]]

function MEDIA.ClearPlaylist(ply)

	if (!ply:IsAdmin()) then return end

	MEDIA.Playlist = {}
	MEDIA.Count = 0
end

--[[
Adds a video to the playlist
--]]

function MEDIA.AddVideo(video, tab)
	if (MEDIA.Playlist[video]) then return end --already exists

	MEDIA.Playlist[video] = tab
	MEDIA.Count = MEDIA.Count + 1
end

--[[
Removes a video to the playlist
--]]

function MEDIA.RemoveVideo(video)
	if (MEDIA.Playlist[video] == nil) then return end --does not exist??

	MEDIA.Playlist[video] = nil
end

--[[`
Gets a video
--]]

function MEDIA.GetVideo(video)
	if (!MEDIA.Playlist[video]) then return nil end

	return MEDIA.Playlist[video]
end
