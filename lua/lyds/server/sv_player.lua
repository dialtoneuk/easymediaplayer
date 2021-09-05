--playlist global
MediaPlayer.Playlist = MediaPlayer.Playlist or {}
--get the player meta
local ply = FindMetaTable("Player")

--sends a message to the player
function ply:SendMediaPlayerMessage(message, tag )
	if (string.len(message) > 125) then return end
	tag = tag or false

	net.Start("MediaPlayer.SendMediaPlayerMessage")
		net.WriteString(message)
		net.WriteBool(tag)
	net.Send(self)
end

--does the initial spawn of a player
function ply:MediaPlayerInitialSpawn()
	if (MediaPlayer.IsSettingTrue("announce_spawn")) then
		self:SendMediaPlayerMessage("This server is running " .. MediaPlayer.Name .. " v" .. MediaPlayer.Version)
		self:SendMediaPlayerMessage("Created by " .. MediaPlayer.Credits.Author)
	end

	if (self:IsAdmin()) then
		MediaPlayer.SendBlacklist(self)
		self:SendMediaPlayerAdminSettings()
		self:ConCommand("media_create_admin_panel")
	end
end

--sends the settings to the player if they are an admin
function ply:SendMediaPlayerAdminSettings()
	if (not self:IsAdmin()) then return end
	net.Start("MediaPlayer.SendMediaPlayerAdminSettings")
	net.WriteTable(MediaPlayer.Settings)
	net.Send(self)
end

--creates a warning box to a player
function ply:SendMediaWarningBox(message, title)
	title = title or "Warning"
	net.Start("MediaPlayer.CreateWarningBox")
	net.WriteString(title)
	net.WriteString(message)
	net.Send(self)
end

--creates a success box on the players screen
function ply:SendMediaSuccessBox(message, title)
	title = title or "Success"
	net.Start("MediaPlayer.CreateSuccessBox")
	net.WriteString(title)
	net.WriteString(message)
	net.Send(self)
end

function ply:SendMediaOptionsBox(message, concommand, title)
	title = title or "Hmmm?"
	net.Start("MediaPlayer.CreateOptionBox")
	net.WriteString(title)
	net.WriteString(message)
	net.Send(self)
end

--gets all of the playlist items the player has personally submitted this server session
function ply:GetSessionVideos(max, start)
	local results = {}
	local count = 0

	for k, v in SortedPairsByMemberValue(MediaPlayer.Session, "LastPlayed", true) do
		count = count + 1
		if (count < start) then continue end
		if (count >= start + max) then break end
		if (v.Owner == nil) then continue end

		if (self:SteamID() == v.Owner.SteamID) then
			results[k] = v
		end
	end

	return results
end

--gets how many items there are in total (since # does not work)
function ply:GetSessionVideosCount()
	local count = 0

	for k, v in pairs(MediaPlayer.Session) do
		if (v.Owner == nil) then continue end

		if (self:SteamID() == v.Owner.SteamID) then
			count = count + 1
		end
	end

	return count
end

--gets all the videos currently on the playlist by this user
function ply:GetVideos()
	local results = {}

	for k, v in pairs(MediaPlayer.Playlist) do
		if (not IsValid(v.Owner)) then continue end
		if (not table.IsEmpty(MediaPlayer.CurrentVideo) and MediaPlayer.CurrentVideo.Video == k) then continue end
		if (v.Owner:SteamID() ~= self:SteamID()) then continue end --not ours
		results[k] = v
	end

	return results
end