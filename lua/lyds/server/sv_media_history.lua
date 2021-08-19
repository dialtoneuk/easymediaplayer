
MediaPlayer.History = MediaPlayer.History or {}

--[[
	Adds a video to our history
--]]

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

	--replace with merge
	MediaPlayer.History[video.Video] = {
		Video = video.Video,
		Title = video.Title,
		Creator = video.Creator,
		Type = video.Type,
		Duration = video.Duration,
		LastPlayed = os.time(),
		Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		},
		Likes = 0,
		Dislikes = 0,
		Plays = 1
	}
end

--[[
	Return true if we have history on this video
--]]

function MediaPlayer.HasVideo(video)
	return MediaPlayer.History[video.Video] != nil
end

--[[
Likes the current video
--]]

function MediaPlayer.LikeCurrentVideo()
	if (table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	local video = MediaPlayer.CurrentVideo

	if (!MediaPlayer.HasVideo(video)) then MediaPlayer.AddToHistory(video) end

	MediaPlayer.History[video.Video].Likes = MediaPlayer.History[video.Video].Likes + 1
end

--[[
	Dislikes a video
--]]

function MediaPlayer.LikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasVideo(video)) then MediaPlayer.AddToHistory(video) end
	MediaPlayer.History[video.Video].Likes = MediaPlayer.History[video.Video].Likes + 1
end

--[[
Dislikes the current video
--]]

function MediaPlayer.DislikeCurrentVideo()
	if (table.IsEmpty(MediaPlayer.CurrentVideo)) then return end
	local video = MediaPlayer.CurrentVideo

	if (!MediaPlayer.HasVideo(video)) then MediaPlayer.AddToHistory(video) end
	if (!MediaPlayer.HasVideo(video)) then MediaPlayer.AddToHistory(video) end

	MediaPlayer.History[video.Video].Dislikes = MediaPlayer.History[video.Video].Dislikes + 1
end

--[[
	Dislikes a video
--]]

function MediaPlayer.DislikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MediaPlayer.HasVideo(video)) then MediaPlayer.AddToHistory(video) end

	MediaPlayer.History[video.Video].Dislikes = MediaPlayer.History[video.Video].Dislikes + 1
end

--[[
	Loads our history
--]]

function MediaPlayer.LoadHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end
	if (!file.Exists("lyds/history.json", "DATA")) then return end

	MediaPlayer.History = util.JSONToTable( file.Read("lyds/history.json") )
end

--[[
	Saves our history to file
--]]

function MediaPlayer.SaveHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/history.json", util.TableToJSON( MediaPlayer.History ))
end
