/*
	Holds our blacklist
*/

MEDIA.Blacklist = MEDIA.Blacklist or {}

/*
Loads the blacklist
*/

function MEDIA.LoadBlacklist()
	if (!file.IsDir("lyds", "DATA")) then return end
	if (!file.Exists("lyds/blacklist.json", "DATA")) then return end

	MEDIA.Blacklist = util.JSONToTable(file.Read("lyds/blacklist.json"))
end

/*
	Saves blacklist
*/

function MEDIA.SaveBlacklist()
	if (!file.IsDir("lyds", "DATA")) then file.CreateDir("lyds", "DATA") end

	file.Write("lyds/blacklist.json", util.TableToJSON(MEDIA.Blacklist))
end

/*
	Adds video to blacklist
*/

function MEDIA.AddToBlacklist(video, ply )
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

	MEDIA.Blacklist[video.Video] = _video
end

/*
	Removes video from blacklist
*/

function MEDIA.RemoveFromBlacklist(video)
	MEDIA.Blacklist[video.Video] = nil
end
