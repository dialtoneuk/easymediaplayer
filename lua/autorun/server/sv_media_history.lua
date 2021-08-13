
MEDIA.History = MEDIA.History or {}

--[[
	Adds a video to our history
--]]

function MEDIA.AddToHistory(video)
	if (MEDIA.History[video.Video]) then
		MEDIA.History[video.Video].Plays = MEDIA.History[video.Video].Plays + 1
		MEDIA.History[video.Video].LastPlayed = os.time()
		MEDIA.History[video.Video].Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}
		return
	end

	MEDIA.History[video.Video] = {
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

function MEDIA.HasVideo(video)
	return MEDIA.History[video.Video] != nil
end

--[[
Likes the current video
--]]

function MEDIA.LikeCurrentVideo()
	if (table.IsEmpty(MEDIA.CurrentVideo)) then return end
	local video = MEDIA.CurrentVideo

	if (!MEDIA.HasVideo(video)) then MEDIA.AddToHistory(video) end

	MEDIA.History[video.Video].Likes = MEDIA.History[video.Video].Likes + 1
end

--[[
	Dislikes a video
--]]

function MEDIA.LikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MEDIA.HasVideo(video)) then MEDIA.AddToHistory(video) end
	MEDIA.History[video.Video].Likes = MEDIA.History[video.Video].Likes + 1
end

--[[
Dislikes the current video
--]]

function MEDIA.DislikeCurrentVideo()
	if (table.IsEmpty(MEDIA.CurrentVideo)) then return end
	local video = MEDIA.CurrentVideo

	if (!MEDIA.HasVideo(video)) then MEDIA.AddToHistory(video) end
	if (!MEDIA.HasVideo(video)) then MEDIA.AddToHistory(video) end

	MEDIA.History[video.Video].Dislikes = MEDIA.History[video.Video].Dislikes + 1
end

--[[
	Dislikes a video
--]]

function MEDIA.DislikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!MEDIA.HasVideo(video)) then MEDIA.AddToHistory(video) end

	MEDIA.History[video.Video].Dislikes = MEDIA.History[video.Video].Dislikes + 1
end

--[[
	Loads our history
--]]

function MEDIA.LoadHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end
	if (!file.Exists("lyds/history.json", "DATA")) then return end

	MEDIA.History = util.JSONToTable( file.Read("lyds/history.json") )
end

--[[
	Saves our history to file
--]]

function MEDIA.SaveHistory()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/history.json", util.TableToJSON( MEDIA.History ))
end
