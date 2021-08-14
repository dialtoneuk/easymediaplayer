--Current vote
MEDIA.CurrentVote = MEDIA.CurrentVote or {}

--All votes
MEDIA.Votes = MEDIA.Votes or {
	--base
	_Vote = {
		Owner = {},  --ply entity, steam id on client
		Type = "Default", --type of Vote
		OnSuccess = function()
			--nothing
		end,
		OnFailire = function()
			--nothing
		end,
		Time = 0, --set by setting
		Count = 0 --votes
	}
}

--[[
	Devs: You can add to this

	! NOTE ! This is merely a code definition of a vote and does not attach its self to a chat command implicity, for that, see sv_media_chatcommands for how
	that works.
--]]

function MEDIA.LoadVotes()

	--Skip video
	local vote = MEDIA.NewKindOfVote()

	vote.Type = "VoteSkip" --this is not the commands name, but its internal type name. Look above in commands to see how we invoke this command by using the value of this key
	vote.Time = 30 --this is a default time and can be overridden in admin settings
	vote.OnSuccess = function()
		MEDIA.SkipVideo()

		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Vote Passed! Skipping video..")
		end
	end

	vote.OnFailire = function()
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Vote has not been skipped!")
		end
	end

	--must copy this too
	MEDIA.RegisterVote(vote)

	--blacklist video
	vote = MEDIA.NewKindOfVote()

	--This is the "key" or name of this vote, so the command to excute this would be media_start_vote VoteBlacklist
	vote.Type = "VoteBlacklist"
	vote.Time = 30
	vote.Required = 3 --at least three players on server
	vote.OnSuccess = function()
		MEDIA.AddToBlacklist(MEDIA.CurrentVideo)
		MEDIA.SkipVideo()

		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Vote Passed! Blacklisting video..")
		end
	end

	vote.OnFailire = function()
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Video has not been blacklisted!")
		end
	end

	MEDIA.RegisterVote(vote)
end

--[[
returns copy of the table above
--]]

function MEDIA.NewKindOfVote()
	return table.Copy(MEDIA.Votes._Vote)
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
		net.WriteTable({
			Owner = {
				Name = ply:GetName()
			},
			StartTime = MEDIA.CurrentVote.StartTime,
			Type = MEDIA.CurrentVote.Type,
			Count = MEDIA.CurrentVote.Count,
			Time = MEDIA.CurrentVote.Time
		})
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
	if (MEDIA.Votes[vote.Type]) then return end

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

	if (MEDIA.GetSetting("media_announce_count").Value == 1 ) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("Votes +1 [" .. MEDIA.CurrentVote.Type .. "] (" .. MEDIA.CurrentVote.Count ..  " / " ..  math.Round( #player.GetAll() / 2 ) .. ")")
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

	if (v.Required or 0 > #player.GetAll()) then ply:SendMessage("Must have at least " .. v.Required .. " players in the server for this vote") return end

	local setting =  MEDIA.GetSetting("media_vote_time") or { Value = 10}

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

	if (MEDIA.GetSetting("media_announce_vote").Value == 1 ) then
		for k,v in pairs(player.GetAll()) do
			v:SendMessage("A vote has been initiated. type !vote to participate!")
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
