--holds all of our banned videos
LydsPlayer.Blacklist = LydsPlayer.Blacklist or {}

--loads our banned videos from file
function LydsPlayer.LoadBlacklist()
	if (!file.IsDir("lyds", "DATA")) then return end
	if (!file.Exists("lyds/blacklist.json", "DATA")) then return end

	LydsPlayer.Blacklist = util.JSONToTable(file.Read("lyds/blacklist.json"))
end

--save the blacklist to file
function LydsPlayer.SaveBlacklist()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/blacklist.json", util.TableToJSON(LydsPlayer.Blacklist))
end

--add a video to a blacklist, video must be a table
function LydsPlayer.AddToBlacklist(video, ply)
	local bannedVideo = table.Copy(video)
	bannedVideo.Admin = {
		Name = "System",
		SteamID = "0"
	}

	if (ply) then
		bannedVideo.Admin = {
			Name = ply:GetName(),
			SteamID = ply:SteamID(),
		}
	end

	if (IsValid(video.Owner)) then
		bannedVideo.Owner = {
			Name = video.Owner:GetName(),
			SteamID = video.Owner:SteamID()
		}
	end

	bannedVideo.DateAdded = os.time()
	LydsPlayer.Blacklist[video.Video] = bannedVideo
end

--removes from banned videos, video must be a table
function LydsPlayer.RemoveFromBlacklist(video)
	LydsPlayer.Blacklist[video.Video] = nil
end
