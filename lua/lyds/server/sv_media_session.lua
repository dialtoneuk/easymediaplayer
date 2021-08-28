
MediaPlayer.Session = MediaPlayer.Session or {}

--adds a video to the servers history
function MediaPlayer.AddToSession(video)

	if (MediaPlayer.Session[video.Video]) then

		if (MediaPlayer.Session[video.Video].Plays == nil ) then
			MediaPlayer.Session[video.Video].Plays = 0
		end

		MediaPlayer.Session[video.Video].Plays = MediaPlayer.Session[video.Video].Plays + 1
		MediaPlayer.Session[video.Video].LastPlayed = os.time()
		MediaPlayer.Session[video.Video].Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}

	else
		local history = table.Copy(video)

		history.Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}

		if (MediaPlayer.ExistsInDatabase(video.Video)) then
			local default = MediaPlayer.GetVideoHistory(video.Video)

			history.Likes = default.Likes or 0
			history.Dislikes = default.Disikes or 0
			history.Plays = default.Plays or 0
			history.LastPlayed =  default.LastPlayed
		else
			history.Likes = 0
			history.Dislikes = 0
			history.Plays = 0
			history.LastPlayed = os.time()
		end

		MediaPlayer.Session[video.Video] = history
	end

	--insert or update
	if (!MediaPlayer.ExistsInDatabase(video.Video)) then
		MediaPlayer.InsertHistory(MediaPlayer.Session[video.Video])
	else
		MediaPlayer.UpdateHistory(video.Video, MediaPlayer.Session[video.Video])
	end
end

--returns true if that video has been played before
function MediaPlayer.HasRecentlyPlayed(video)
	return MediaPlayer.Session[video.Video] != nil
end

--likes the current playing video
function MediaPlayer.LikeCurrentVideo()
	MediaPlayer.LikeVideo(MediaPlayer.CurrentVideo or {})
end

--likes a video
function MediaPlayer.LikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasRecentlyPlayed(video)) then MediaPlayer.AddToSession(video) end

	MediaPlayer.Session[video.Video].Likes = MediaPlayer.Session[video.Video].Likes + 1
end

--likes a the current video
function MediaPlayer.LikeCurrentVideo()
	MediaPlayer.DislikeVideo(MediaPlayer.CurrentVideo or {})
end

--dislikes the current video
function MediaPlayer.DislikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasRecentlyPlayed(video)) then MediaPlayer.AddToSession(video) end

	MediaPlayer.Session[video.Video].Dislikes = MediaPlayer.Session[video.Video].Dislikes + 1
end

--saves our history to file
function MediaPlayer.SaveSession()
	if (!file.IsDir("lyds/sessions/", "DATA")) then file.CreateDir("lyds/sessions/", "DATA") end

	file.Write("lyds/sessions/" .. game.GetMap() .. "_" .. os.date("%A_%B%d_%y %H_%M_%S") .. ".json", util.TableToJSON( MediaPlayer.Session ))
end
