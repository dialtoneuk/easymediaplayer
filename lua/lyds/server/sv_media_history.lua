
MediaPlayer.History = MediaPlayer.History or {}

--adds a video to the servers history
function MediaPlayer.AddToHistory(video)
	if (MediaPlayer.History[video.Video]) then
		MediaPlayer.History[video.Video].Plays = MediaPlayer.History[video.Video].Plays + 1
		MediaPlayer.History[video.Video].LastPlayed = os.time()
		MediaPlayer.History[video.Video].Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}
		return
	end

	local history = table.Copy(video)
	history.Owner = {
		Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
		SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
	}
	history.Likes = 0
	history.Dislikes = 0
	history.LastPlayed = os.time()

	MediaPlayer.History[video.Video] = history
end

--returns true if that video has been played before
function MediaPlayer.HasHistory(video)
	return MediaPlayer.History[video.Video] != nil
end

--likes the current playing video
function MediaPlayer.LikeCurrentVideo()
	MediaPlayer.LikeVideo(MediaPlayer.CurrentVideo or {})
end

--likes a video
function MediaPlayer.LikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasHistory(video)) then MediaPlayer.AddToHistory(video) end

	MediaPlayer.History[video.Video].Likes = MediaPlayer.History[video.Video].Likes + 1
end

--likes a the current video
function MediaPlayer.LikeCurrentVideo()
	MediaPlayer.DislikeVideo(MediaPlayer.CurrentVideo or {})
end

--dislikes the current video
function MediaPlayer.DislikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasHistory(video)) then MediaPlayer.AddToHistory(video) end

	MediaPlayer.History[video.Video].Dislikes = MediaPlayer.History[video.Video].Dislikes + 1
end

--loads the servers history
function MediaPlayer.LoadHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end
	if (!file.Exists("lyds/history.json", "DATA")) then return end

	MediaPlayer.History = util.JSONToTable( file.Read("lyds/history.json") )
end

--saves our history to file
function MediaPlayer.SaveHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/history.json", util.TableToJSON( MediaPlayer.History ))
end
