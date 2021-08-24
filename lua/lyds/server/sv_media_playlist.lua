--playlist global
MediaPlayer.Playlist = MediaPlayer.Playlist or {}

--the current video
MediaPlayer.CurrentVideo = MediaPlayer.CurrentVideo or {}

--how many videos posted since start, used for position
MediaPlayer.Count = MediaPlayer.Count or 0

--Copy table
MediaPlayer.BaseVideo = {
	Video = "38enrQGRDhA",
	Title = "Default",
	Creator = "Default",
	Custom = {}, --used with direct mp3s
	Views = 1,
	Type = MediaPlayer.MediaType.YOUTUBE,
	Duration = 1,
	Position = 1,
	StartTime = 0, --Used for time tracking
	Player = {}, --this should be an array of the different kinds of quality of embeds
	Owner = {} --this will be a player entity on the servers end and a table on the clients end
}

--removes a video but checks that player owns it
function MediaPlayer.RemovePlayerVideo(id, ply)
	if (MediaPlayer.Playlist[id] == nil) then return end -- already in there
	local video = MediaPlayer.GetVideo(id)

	if ( video == nil) then return end
	if (!IsValid(video.Owner)) then return end
	if (video.Owner:SteamID() != ply:SteamID()) then return end --not ours

	MediaPlayer.RemoveVideo(id)
	ply:SendMessage("Video successfully removed!")
end

--removes all a players videos
function MediaPlayer.RemovePlayerVideos(ply)
	for k,v in pairs(MediaPlayer.Playlist) do
		if (!IsValid(v.Owner)) then continue end
		if (!table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == v.Video) then continue end
		if (v.Owner:SteamID() != ply:SteamID()) then continue end --not ours

		MediaPlayer.RemoveVideo(v.Video)
	end
end

--returns true if a player can submit a video
function MediaPlayer.CanSubmitVideo(id, ply )

	if (MediaPlayer.Playlist[ id ]) then
		ply:SendMessage("This video is already in the playlist!")
		return false
	end

	if (MediaPlayer.Blacklist[ id ]) then
		ply:SendMessage("This video is banned!")
		return false
	end

	if (MediaPlayer.HasCooldown(ply, "Play")) then
		ply:SendMessage("Wait a bit before playing something else")
		return false
	end

	if (MediaPlayer.GetSetting("playlist_capacity") == MediaPlayer.Count ) then
		ply:SendMessage("The playlist is at full capacity")
		return false
	end

	return true
end

--gets videos on the playlist ordered by position
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

--returns true if we have next
function MediaPlayer.HasNext()
	return !table.IsEmpty(MediaPlayer.Playlist)
end


--gets the next item in the playlist
function MediaPlayer.Next()
	if (!MediaPlayer.HasNext() ) then return end

	for k,v in SortedPairsByMemberValue(MediaPlayer.Playlist, "Position") do
		return v
	end
end

--gets a brand new video which is then built upon to be put into the playlist
function MediaPlayer.GetNewVideo()
	return table.Copy(MediaPlayer.BaseVideo)
end

--clears the current playlist entirely
function MediaPlayer.ClearPlaylist(ply)

	if (!ply:IsAdmin()) then return end

	MediaPlayer.Playlist = {}
	MediaPlayer.Count = 0
end

--adds a video to the playlist
function MediaPlayer.AddVideo(video, tab)
	if (MediaPlayer.Playlist[video]) then return end --already exists

	MediaPlayer.Playlist[video] = tab
	MediaPlayer.Count = MediaPlayer.Count + 1 --used for position
end

--removes a video from the playlist
function MediaPlayer.RemoveVideo(video)
	if (MediaPlayer.Playlist[video] == nil) then return end --does not exist??

	MediaPlayer.Playlist[video] = nil
end

--gets a video from the playlist
function MediaPlayer.GetVideo(video)
	if (!MediaPlayer.Playlist[video]) then return nil end

	return MediaPlayer.Playlist[video]
end
