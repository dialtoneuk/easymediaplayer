--Current vote
MEDIA.CurrentVote = MEDIA.CurrentVote or {}

--Computed votes are put here and are not effected by file changes making this file easy to work with
MEDIA.Votes = MEDIA.Votes or {

}

--base vote to copy off of so we don't get missing fields
MEDIA.BaseVote = {
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

MEDIA.RegisteredVotes = {
	--this is the type of vote and what we'll use to grab this vote
	VoteSkip = {
		Time = 30,
		OnSuccess = function()
			MEDIA.SkipVideo()

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
			MEDIA.AddToBlacklist(MEDIA.CurrentVideo)
			MEDIA.SkipVideo()

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

function MEDIA.LoadVotes()

	hook.Call("MEDIA.PreloadRegisteredVotes")

	for k,v in pairs(MEDIA.RegisteredVotes) do
		v = table.Merge(MEDIA.GetNewVote(), v)
		v.Type = k

		--register it
		MEDIA.RegisterVote(v)
	end
end

function MEDIA.AddRegisteredVotes(tab)

	for k,v in pairs(tab) do

		if (MEDIA.RegisteredVotes[k] != nil ) then
			warning(k .. " is an already registered vote")
		end

		MEDIA.RegisteredVotes[k] = v
	end
end

--[[
returns copy of the table above
--]]

function MEDIA.GetNewVote()
	return table.Copy(MEDIA.BaseVote)
end

--[[
Broadcasts vote to the server
--]]

function MEDIA.BroadcastVote()
	if (!MEDIA.HasCurrentVote()) then return end

	for k,v in pairs(player.GetAll()) do
		MEDIA.SendVoteToPlayer(v)
	end
end

--[[
Broadcasts End vote to the server
--]]


function MEDIA.BroadcastEndVote()
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("Voted", false )
		MEDIA.SendEndVoteToPlayer(v)
	end
end

--[[
Broadcasts vote to the player
--]]

function MEDIA.SendVoteToPlayer( ply )
	if (!MEDIA.HasCurrentVote()) then return end


	net.Start("MEDIA.NewVote")
		--remove the owner field
		local t = table.Merge({
			Owner = {
				Name = ply:GetName(),
				SteamID = ply:SteamID()
			},
		}, MEDIA.CurrentVote)

		net.WriteTable(t)
	net.Send(ply)
end

--[[
Notifys the player that a vote has ended
--]]

function MEDIA.SendEndVoteToPlayer( ply )
	net.Start("MEDIA.EndVote")
	net.Send(ply)
end

--[[
Adds a kind of vote to the table
--]]

function MEDIA.RegisterVote(vote)
	MEDIA.Votes[vote.Type] = vote
end

--[[
Gets a kind of vote to the table
--]]

function MEDIA.GetKindOfVote(vote)
	if ( !MEDIA.Votes[vote]) then return end

	return MEDIA.Votes[vote]
end

--[[*
Returns true if we have a current vote going on
*--]]

function MEDIA.HasCurrentVote() return !table.IsEmpty(MEDIA.CurrentVote) end

function MEDIA.AddToCount()
	if (!MEDIA.HasCurrentVote()) then return end

	MEDIA.CurrentVote.Count = MEDIA.CurrentVote.Count + 1

	if (MEDIA.IsSettingTrue("media_announce_count")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Votes +1 to " .. MEDIA.CurrentVote.Type .. " (" .. MEDIA.CurrentVote.Count ..  " / " .. MEDIA.CurrentVote.Required  .. ")")
		end

		if (MEDIA.HasPassed() ) then
			MEDIA.CurrentVote.OnSuccess()
			MEDIA.CurrentVote = {}
			MEDIA.BroadcastEndVote()
			return
		end
	end

	MEDIA.BroadcastVote()
end

--[[
Starts a vote
--]]

function MEDIA.StartVote(vote, ply)
	if ( !MEDIA.Votes[vote]) then return end

	local v = table.Copy(MEDIA.Votes[vote])
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

	local setting = MEDIA.GetSetting("media_vote_time") or { Value = 10 }

	v.Owner = ply
	v.StartTime = CurTime()
	v.Time = setting.Value
	v.CurrentVideo = MEDIA.CurrentVideo or {}

	MEDIA.ExecuteVote(v)
end

--[[
Executes a vote
--]]

function MEDIA.ExecuteVote(vote)
	if (!MEDIA.Votes[vote.Type]) then return end
	if (MEDIA.CurrentVote.Type == vote.Type ) then return end
	MEDIA.CurrentVote = vote

	local count = #player.GetAll()

	if (count == 1) then
		vote.OnSuccess()
		MEDIA.CurrentVote = {}
		return
	end

	if (MEDIA.IsSettingTrue("media_announce_vote")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("A vote has been initiated. type !vote to participate! " .. vote.Required .. " votes are required for this to pass!")
		end
	end

	MEDIA.BroadcastVote()

	timer.Simple(vote.Time, function()

		if (table.IsEmpty(MEDIA.CurrentVideo) ) then
			MEDIA.BroadcastEndVote()
			return
		end

		if (MEDIA.CurrentVideo == nil or table.IsEmpty(MEDIA.CurrentVideo) ) then return end

		if (vote.CurrentVideo != nil and !table.IsEmpty(vote.CurrentVideo) and (vote.CurrentVideo.Video != MEDIA.CurrentVideo.Video) ) then
			return end

			if (MEDIA.HasPassed()) then
				vote.OnSuccess()
			else
				vote.OnFailire()
			end

			MEDIA.CurrentVote = {}
			MEDIA.BroadcastEndVote()
		end)
	end

	--[[
	Return true if a vote passed
	--]]

	function MEDIA.HasPassed()

		if (!MEDIA.HasCurrentVote()) then return false end
		if (MEDIA.CurrentVote.Count == 0 ) then return false end

		local count = #player.GetAll()

		if (MEDIA.CurrentVote.Count <= math.floor( count / 2 ) ) then return false end

		return true
	end

	--[[
	Hook call
	--]]

	hook.Run("MEDIA.VotingLoaded")
