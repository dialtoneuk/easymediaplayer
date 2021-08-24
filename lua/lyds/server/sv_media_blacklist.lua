--holds all of our banned videos
MediaPlayer.Blacklist = MediaPlayer.Blacklist or {}

--loads our banned videos from file
function MediaPlayer.LoadBlacklist()
	if (!file.IsDir("lyds", "DATA")) then return end
	if (!file.Exists("lyds/blacklist.json", "DATA")) then return end

	MediaPlayer.Blacklist = util.JSONToTable(file.Read("lyds/blacklist.json"))
end

--save the blacklist to file
function MediaPlayer.SaveBlacklist()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/blacklist.json", util.TableToJSON(MediaPlayer.Blacklist))
end

--add a video to a blacklist, video must be a table
function MediaPlayer.AddToBlacklist(video, ply)
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
	MediaPlayer.Blacklist[video.Video] = bannedVideo
end

--removes from banned videos, video must be a table
function MediaPlayer.RemoveFromBlacklist(video)
	MediaPlayer.Blacklist[video.Video] = nil
end
