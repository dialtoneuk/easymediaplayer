--playlist global
MEDIA.Playlist = MEDIA.Playlist or {}

--get the player meta
local ply = FindMetaTable("Player")

--[[
sends a message to the player
--]]

function ply:SendMessage(message)

	if (string.len(message) > 125) then return end

	net.Start("MEDIA.SendMessage")
		net.WriteString(message)
	net.Send(self)
end

--[[
	Players initial spawn
--]]

function ply:DoInitialSpawn()
	self:SendMessage("This server is running " .. MEDIA.Name .. " v" .. MEDIA.Version )
	self:SendMessage("Created by " .. MEDIA.Credits.Author )

	if (self:IsAdmin()) then
		MEDIA.SendBlacklist(self)
		self:SendAdminSettings()
		self:ConCommand("media_create_admin_panel")
	end
end

--[[
Sends the servers settings to the client
--]]

function ply:SendAdminSettings()
	if (!self:IsAdmin()) then return end

	net.Start("MEDIA.SendAdminSettings")
	net.WriteTable(MEDIA.Settings)
	net.Send(self)
end

--[[
Removes a video
--]]

function ply:RemoveVideo(id)
	if (MEDIA.Playlist[id] == nil) then return end -- already in there

	local video = MEDIA.GetVideo(id)

	if ( video == nil) then return end
	if (!IsValid(video.Owner)) then return end
	if (video.Owner:SteamID() != self:SteamID()) then return end --not ours

	MEDIA.RemoveVideo(video)
end

--[[
Gets a players personal history
--]]

function ply:GetPersonalHistory(max, start )
	local results = {}
	local count = 0

	for k,v in SortedPairsByMemberValue(MEDIA.History, "LastPlayed", true ) do
		count = count + 1

		if ( count < start) then continue end
		if ( count >= start + max ) then break end
		if (v.Owner == nil) then continue end

		if (self:SteamID() == v.Owner.SteamID ) then
			results[k] = v
		end
	end

	return results
end

--[[
Used for pages
--]]

function ply:GetPersonalHistoryCount()

	local count = 0

	for k,v in pairs(MEDIA.History) do
		if (v.Owner == nil) then continue end

		if (self:SteamID() == v.Owner.SteamID) then
			count = count + 1
		end
	end

	return count
end

--[[
Gets the players videos
--]]

function ply:GetVideos()
	local results = {}

	for k,v in pairs(MEDIA.Playlist) do
		if (!IsValid(v.Owner)) then continue end
		if (!table.IsEmpty(MEDIA.CurrentVideo) and MEDIA.CurrentVideo.Video == k) then continue end
		if (v.Owner:SteamID() != self:SteamID()) then continue end --not ours

		results[k] = v
	end

	return results
end

--[[
Removes all the users videos
--]]

function ply:RemoveVideos()
	for k,v in pairs(MEDIA.Playlist) do
		if (!IsValid(v.Owner)) then continue end
		if (!table.IsEmpty(MEDIA.CurrentVideo) and MEDIA.CurrentVideo.Video == v.Video) then continue end
		if (v.Owner:SteamID() != self:SteamID()) then continue end --not ours

		MEDIA.RemoveVideo(v.Video)
	end
end
