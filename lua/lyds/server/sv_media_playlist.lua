--playlist global
LydsPlayer.Playlist = LydsPlayer.Playlist or {}

--the current video
LydsPlayer.CurrentVideo = LydsPlayer.CurrentVideo or {}

--how many videos posted since start, used for position
LydsPlayer.Count = LydsPlayer.Count or 0

--Copy table
LydsPlayer.BaseVideo = {
	Video = "38enrQGRDhA",
	Title = "Default",
	Creator = "Default",
	Custom = {}, --used with direct mp3s
	Views = 1,
	Type = LydsPlayer.MediaType.YOUTUBE,
	Duration = 1,
	Position = 1,
	StartTime = 0, --Used for time tracking
	Player = {}, --this should be an array of the different kinds of quality of embeds
	Owner = {} --this will be a player entity on the servers end and a table on the clients end
}

--removes a video but checks that player owns it
function LydsPlayer.RemovePlayerVideo(id, ply)
	if (LydsPlayer.Playlist[id] == nil) then return end -- already in there
	local video = LydsPlayer.GetVideo(id)

	if ( video == nil) then return end
	if (!IsValid(video.Owner)) then return end
	if (video.Owner:SteamID() != ply:SteamID()) then return end --not ours

	LydsPlayer.RemoveVideo(id)
	ply:SendMediaPlayerMessage("Video successfully removed!")
end

--removes all a players videos
function LydsPlayer.RemovePlayerVideos(ply)
	for k,v in pairs(LydsPlayer.Playlist) do
		if (!IsValid(v.Owner)) then continue end
		if (!table.IsEmpty(LydsPlayer.CurrentVideo) and LydsPlayer.CurrentVideo.Video == v.Video) then continue end
		if (v.Owner:SteamID() != ply:SteamID()) then continue end --not ours

		LydsPlayer.RemoveVideo(v.Video)
	end
end

--returns true if a player can submit a video
function LydsPlayer.CanSubmitVideo(id, ply )

	if (LydsPlayer.Playlist[ id ]) then
		ply:SendMediaPlayerMessage("This video is already in the playlist!")
		return false
	end

	if (LydsPlayer.Blacklist[ id ]) then
		ply:SendMediaWarningBox("That video is banned!")
		return false
	end

	if (LydsPlayer.HasCooldown(ply, "Play")) then
		ply:SendMediaPlayerMessage("Wait a bit before playing something else")
		return false
	end

	if (LydsPlayer.GetSetting("playlist_capacity") == LydsPlayer.Count ) then
		ply:SendMediaPlayerMessage("The playlist is at full capacity")
		return false
	end

	return true
end

--gets videos on the playlist ordered by position
function LydsPlayer.GetVideos(owner, limit)
	local results = {}
	local max = limit or 1000

	for k,v in SortedPairsByMemberValue(LydsPlayer.Playlist, "Position") do
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

--returns true if we have next
function LydsPlayer.HasNext()
	return !table.IsEmpty(LydsPlayer.Playlist)
end


--gets the next item in the playlist
function LydsPlayer.Next()
	if (!LydsPlayer.HasNext() ) then return end

	for k,v in SortedPairsByMemberValue(LydsPlayer.Playlist, "Position") do
		return v
	end
end

--gets a brand new video which is then built upon to be put into the playlist
function LydsPlayer.GetNewVideo()
	return table.Copy(LydsPlayer.BaseVideo)
end

--clears the current playlist entirely
function LydsPlayer.ClearPlaylist(ply)

	if (!ply:IsAdmin()) then return end

	LydsPlayer.Playlist = {}
	LydsPlayer.Count = 0
end

--adds a video to the playlist
function LydsPlayer.AddVideo(video, tab)
	if (LydsPlayer.Playlist[video]) then return end --already exists

	LydsPlayer.Playlist[video] = tab
	LydsPlayer.Count = LydsPlayer.Count + 1 --used for position
end

--removes a video from the playlist
function LydsPlayer.RemoveVideo(video)
	if (LydsPlayer.Playlist[video] == nil) then return end --does not exist??

	LydsPlayer.Playlist[video] = nil
end

--gets a video from the playlist
function LydsPlayer.GetVideo(video)
	if (!LydsPlayer.Playlist[video]) then return nil end

	return LydsPlayer.Playlist[video]
end
