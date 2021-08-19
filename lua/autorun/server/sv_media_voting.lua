--Current vote
MediaPlayer.CurrentVote = MediaPlayer.CurrentVote or {}

--Computed votes are put here and are not effected by file changes making this file easy to work with
MediaPlayer.Votes = MediaPlayer.Votes or {

}

--base vote to copy off of so we don't get missing fields
MediaPlayer.BaseVote = {
	Owner = {},  --ply entity, steam id on client
	Type = "Default", --type of Vote
	Required = 1,
	OnSuccess = function()
		--nothing
	end,
	OnFailire = function()
		--nothing
	end,
	OnStart = function()
		return true
	end,
	Time = 0, --set by setting
	Count = 0 --votes
}

--[[
	Devs: You can add to this

	! NOTE ! This is merely a code definition of a vote and does not attach its self to a chat command implicity, for that, see sv_media_chatcommands for how
	that works.
--]]

MediaPlayer.RegisteredVotes = {
	--this is the type of vote and what we'll use to grab this vote
	VoteSkip = {
		Time = 30,
		OnSuccess = function()
			MediaPlayer.SkipVideo()

			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Vote Passed! Skipping video..")
			end
		end,
		OnFailire = function()
			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Vote has not been skipped!")
			end
		end
	},
	--!voteban
	VoteBlacklist = {
		Time = 45,
		Required = 3, --two thirds of the server must agree
		OnSuccess = function()
			MediaPlayer.AddToBlacklist(MediaPlayer.CurrentVideo)
			MediaPlayer.SkipVideo()

			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Vote Passed! Blacklisting video..")
			end
		end,
		OnFailire = function()
			for k,v in pairs(player.GetAll()) do
				v:SendMessage("Video has not been blacklisted!")
			end
		end
	}
}

--[[

]]--

function MediaPlayer.LoadVotes()

	hook.Call("MediaPlayer.PreloadRegisteredVotes")

	for k,v in pairs(MediaPlayer.RegisteredVotes) do
		v = table.Merge(MediaPlayer.GetNewVote(), v)
		v.Type = k

		--register it
		MediaPlayer.RegisterVote(v)
	end
end

function MediaPlayer.AddRegisteredVotes(tab)

	for k,v in pairs(tab) do

		if (MediaPlayer.RegisteredVotes[k] != nil ) then
			warning(k .. " is an already registered vote")
		end

		MediaPlayer.RegisteredVotes[k] = v
	end
end

--[[
returns copy of the table above
--]]

function MediaPlayer.GetNewVote()
	return table.Copy(MediaPlayer.BaseVote)
end

--[[
Broadcasts vote to the server
--]]

function MediaPlayer.BroadcastVote()
	if (!MediaPlayer.HasCurrentVote()) then return end

	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendVoteToPlayer(v)
	end
end

--[[
Broadcasts End vote to the server
--]]


function MediaPlayer.BroadcastEndVote()
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("Voted", false )
		MediaPlayer.SendEndVoteToPlayer(v)
	end
end

--[[
Broadcasts vote to the player
--]]

function MediaPlayer.SendVoteToPlayer( ply )
	if (!MediaPlayer.HasCurrentVote()) then return end


	net.Start("MediaPlayer.NewVote")
		--remove the owner field
		local t = table.Merge({
			Owner = {
				Name = ply:GetName(),
				SteamID = ply:SteamID()
			},
		}, MediaPlayer.CurrentVote)

		net.WriteTable(t)
	net.Send(ply)
end

--[[
Notifys the player that a vote has ended
--]]

function MediaPlayer.SendEndVoteToPlayer( ply )
	net.Start("MediaPlayer.EndVote")
	net.Send(ply)
end

--[[
Adds a kind of vote to the table
--]]

function MediaPlayer.RegisterVote(vote)
	MediaPlayer.Votes[vote.Type] = vote
end

--[[
Gets a kind of vote to the table
--]]

function MediaPlayer.GetKindOfVote(vote)
	if ( !MediaPlayer.Votes[vote]) then return end

	return MediaPlayer.Votes[vote]
end

--[[*
Returns true if we have a current vote going on
*--]]

function MediaPlayer.HasCurrentVote() return !table.IsEmpty(MediaPlayer.CurrentVote) end

function MediaPlayer.AddToCount()
	if (!MediaPlayer.HasCurrentVote()) then return end

	MediaPlayer.CurrentVote.Count = MediaPlayer.CurrentVote.Count + 1

	if (MediaPlayer.IsSettingTrue("MediaPlayer_announce_count")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Votes +1 to " .. MediaPlayer.CurrentVote.Type .. " (" .. MediaPlayer.CurrentVote.Count ..  " / " .. MediaPlayer.CurrentVote.Required  .. ")")
		end

		if (MediaPlayer.HasPassed() ) then
			MediaPlayer.CurrentVote.OnSuccess()
			MediaPlayer.CurrentVote = {}
			MediaPlayer.BroadcastEndVote()
			return
		end
	end

	MediaPlayer.BroadcastVote()
end

--[[
Starts a vote
--]]

function MediaPlayer.StartVote(vote, ply)
	if ( !MediaPlayer.Votes[vote]) then return end

	local v = table.Copy(MediaPlayer.Votes[vote])
	local count = table.Count( player.GetAll() )
	local req = v.Required or 1

	if (req == 1 ) then
		v.Required = math.floor(count / 2)
	else
		v.Required = count - math.floor(count / req)
	end

	if (v.Required >= count) then ply:SendMessage("Must have at over " .. v.Required .. " players in the server for this vote, there is currently " .. count) return end

	if (v.OnStart != nil ) then
		local result = v.OnStart()

		if (result == false ) then
			ply:SendMessage("Unable to start vote")
			return
		end
	end

	local setting = MediaPlayer.GetSetting("MediaPlayer_vote_time") or { Value = 10 }

	v.Owner = ply
	v.StartTime = CurTime()
	v.Time = setting.Value
	v.CurrentVideo = MediaPlayer.CurrentVideo or {}

	MediaPlayer.ExecuteVote(v)
end

--[[
Executes a vote
--]]

function MediaPlayer.ExecuteVote(vote)
	if (!MediaPlayer.Votes[vote.Type]) then return end
	if (MediaPlayer.CurrentVote.Type == vote.Type ) then return end
	MediaPlayer.CurrentVote = vote

	local count = #player.GetAll()

	if (count == 1) then
		vote.OnSuccess()
		MediaPlayer.CurrentVote = {}
		return
	end

	if (MediaPlayer.IsSettingTrue("MediaPlayer_announce_vote")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("A vote has been initiated. type !vote to participate! " .. vote.Required .. " votes are required for this to pass!")
		end
	end

	MediaPlayer.BroadcastVote()

	timer.Simple(vote.Time, function()

		if (table.IsEmpty(MediaPlayer.CurrentVideo) ) then
			MediaPlayer.BroadcastEndVote()
			return
		end

		if (MediaPlayer.CurrentVideo == nil or table.IsEmpty(MediaPlayer.CurrentVideo) ) then return end

		if (vote.CurrentVideo != nil and !table.IsEmpty(vote.CurrentVideo) and (vote.CurrentVideo.Video != MediaPlayer.CurrentVideo.Video) ) then
			return end

			if (MediaPlayer.HasPassed()) then
				vote.OnSuccess()
			else
				vote.OnFailire()
			end

			MediaPlayer.CurrentVote = {}
			MediaPlayer.BroadcastEndVote()
		end)
	end

	--[[
	Return true if a vote passed
	--]]

	function MediaPlayer.HasPassed()

		if (!MediaPlayer.HasCurrentVote()) then return false end
		if (MediaPlayer.CurrentVote.Count == 0 ) then return false end

		local count = #player.GetAll()

		if (MediaPlayer.CurrentVote.Count <= math.floor( count / 2 ) ) then return false end

		return true
	end

	--[[
	Hook call
	--]]

	hook.Run("MediaPlayer.VotingLoaded")
