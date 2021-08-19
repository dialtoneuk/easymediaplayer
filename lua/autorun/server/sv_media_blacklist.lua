--[[
	Holds our blacklist
--]]

MediaPlayer.Blacklist = MediaPlayer.Blacklist or {}

--[[
Loads the blacklist
--]]

function MediaPlayer.LoadBlacklist()
	if (!file.IsDir("lyds", "DATA")) then return end
	if (!file.Exists("lyds/blacklist.json", "DATA")) then return end

	MediaPlayer.Blacklist = util.JSONToTable(file.Read("lyds/blacklist.json"))
end

--[[
	Saves blacklist
--]]

function MediaPlayer.SaveBlacklist()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/blacklist.json", util.TableToJSON(MediaPlayer.Blacklist))
end

--[[
	Adds video to blacklist
--]]

function MediaPlayer.AddToBlacklist(video, ply )
	if (!ply:IsAdmin() ) then return end

	local _video = table.Copy(video)

	_video.Admin = {
		Name = ply:GetName(),
		SteamID = ply:SteamID(),
	}

	_video.Owner = {
		Name = video.Owner:GetName(),
		SteamID = video.Owner:SteamID()
	}

	_video.DateAdded = os.time()

	MediaPlayer.Blacklist[video.Video] = _video
end

--[[
	Removes video from blacklist
--]]

function MediaPlayer.RemoveFromBlacklist(video)
	MediaPlayer.Blacklist[video.Video] = nil
end
