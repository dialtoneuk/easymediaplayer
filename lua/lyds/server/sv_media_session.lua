
LydsPlayer.Session = LydsPlayer.Session or {}

--adds a video to the servers history
function LydsPlayer.AddToSession(video)

	if (LydsPlayer.Session[video.Video]) then

		if (LydsPlayer.Session[video.Video].Plays == nil ) then
			LydsPlayer.Session[video.Video].Plays = 0
		end

		LydsPlayer.Session[video.Video].Plays = LydsPlayer.Session[video.Video].Plays + 1
		LydsPlayer.Session[video.Video].LastPlayed = os.time()
		LydsPlayer.Session[video.Video].Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}

	else
		local history = table.Copy(video)

		history.Owner = {
			Name = video.Owner:GetName() or video.Owner.Name or "Unknown",
			SteamID = video.Owner:SteamID() or video.Owner.SteamID or "Unknown"
		}

		if (LydsPlayer.ExistsInDatabase(video.Video)) then
			local default = LydsPlayer.GetVideoHistory(video.Video)

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

		LydsPlayer.Session[video.Video] = history
	end

	--insert or update
	if (!LydsPlayer.ExistsInDatabase(video.Video)) then
		LydsPlayer.InsertHistory(LydsPlayer.Session[video.Video])
	else
		LydsPlayer.UpdateHistory(video.Video, LydsPlayer.Session[video.Video])
	end
end

--returns true if that video has been played before
function LydsPlayer.HasRecentlyPlayed(video)
	return LydsPlayer.Session[video.Video] != nil
end

--likes the current playing video
function LydsPlayer.LikeCurrentVideo()
	LydsPlayer.LikeVideo(LydsPlayer.CurrentVideo or {})
end

--likes a video
function LydsPlayer.LikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!LydsPlayer.HasRecentlyPlayed(video)) then LydsPlayer.AddToSession(video) end

	LydsPlayer.Session[video.Video].Likes = LydsPlayer.Session[video.Video].Likes + 1
end

--likes a the current video
function LydsPlayer.LikeCurrentVideo()
	LydsPlayer.DislikeVideo(LydsPlayer.CurrentVideo or {})
end

--dislikes the current video
function LydsPlayer.DislikeVideo(video)
	if (table.IsEmpty(video)) then return end
	if (!LydsPlayer.HasRecentlyPlayed(video)) then LydsPlayer.AddToSession(video) end

	LydsPlayer.Session[video.Video].Dislikes = LydsPlayer.Session[video.Video].Dislikes + 1
end

--saves our history to file
function LydsPlayer.SaveSession()
	if (!file.IsDir("lyds/sessions/", "DATA")) then file.CreateDir("lyds/sessions/", "DATA") end

	file.Write("lyds/sessions/" .. game.GetMap() .. "_" .. os.date("%A_%B%d_%y %H_%M_%S") .. ".json", util.TableToJSON( LydsPlayer.Session ))
end
