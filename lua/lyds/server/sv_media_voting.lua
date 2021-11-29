--Current vote
LydsPlayer.CurrentVote = LydsPlayer.CurrentVote or {}

--Computed votes are put here and are not effected by file changes making this file easy to work with
LydsPlayer.Votes = LydsPlayer.Votes or {

}

--base vote to copy off of so we don't get missing fields
LydsPlayer.BaseVote = {
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

--registered votes
LydsPlayer.RegisteredVotes = {
	--this is the type of vote and what we'll use to grab this vote
	VoteSkip = {
		Time = 30,
		OnSuccess = function()
			LydsPlayer.SkipVideo()

			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Vote Passed! Skipping video..")
			end
		end,
		OnFailire = function()
			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Video has not been skipped!")
			end
		end
	},
	--!voteban
	VoteBlacklist = {
		Time = 45,
		Required = 3, --two thirds of the server must agree
		OnSuccess = function()
			LydsPlayer.AddToBlacklist(LydsPlayer.CurrentVideo)
			LydsPlayer.SkipVideo()

			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Vote Passed! Blacklisting video..")
			end
		end,
		OnFailire = function()
			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Video has not been blacklisted!")
			end
		end
	}
}

--loads our votes
function LydsPlayer.LoadVotes()

	hook.Call("LydsPlayer.PreloadRegisteredVotes")

	for k,v in pairs(LydsPlayer.RegisteredVotes) do
		v = table.Merge(LydsPlayer.GetNewVote(), table.Copy(v))
		v.Type = k
		v.Required = v.Required

		--register it
		LydsPlayer.RegisterVote(v)
	end

	--called after votes are loaded
	hook.Run("LydsPlayer.VotesLoaded")
end

--adds a new vote to be loaded
function LydsPlayer.AddRegisteredVotes(tab)

	for k,v in pairs(tab) do

		if (LydsPlayer.RegisteredVotes[k] != nil ) then
			warning(k .. " is an already registered vote")
		end

		LydsPlayer.RegisteredVotes[k] = v
	end
end

--returns a copy of the base vote
function LydsPlayer.GetNewVote()
	return table.Copy(LydsPlayer.BaseVote)
end

--broadcasts the current vote to the server
function LydsPlayer.BroadcastVote()
	if (!LydsPlayer.HasCurrentVote()) then return end

	for k,v in pairs(player.GetAll()) do
		LydsPlayer.SendVoteToPlayer(v)
	end
end

--broadcsts the end of the vote
function LydsPlayer.BroadcastEndVote()
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("LydsPlayer.Voted", false )
		LydsPlayer.SendEndVoteToPlayer(v)
	end
end

--broadcasts a new vote to a player
function LydsPlayer.SendVoteToPlayer( ply )
	if (!LydsPlayer.HasCurrentVote()) then return end


	net.Start("LydsPlayer.NewVote")
		--remove the owner field
		local t = table.Copy(LydsPlayer.CurrentVote)

		t.Owner = {
			Name = ply:GetName(),
			SteamID = ply:SteamID()
		}

		if (t.CurrentVideo) then t.CurrentVideo = nil end

		for k,v in pairs(t) do
			if (type(v) == "function") then
				t[k] = nil
			end
		end

		net.WriteTable(t)
	net.Send(ply)
end

--notifies a player that a vote has ended
function LydsPlayer.SendEndVoteToPlayer( ply )
	net.Start("LydsPlayer.EndVote")
	net.Send(ply)
end

--adds a new kind of vote ready for use
function LydsPlayer.RegisterVote(vote)
	LydsPlayer.Votes[vote.Type] = vote
end

--gets that kind of vote
function LydsPlayer.GetKindOfVote(vote)
	if ( !LydsPlayer.Votes[vote]) then return end

	return LydsPlayer.Votes[vote]
end

--returns true if we havea current vote
function LydsPlayer.HasCurrentVote()
	return !table.IsEmpty(LydsPlayer.CurrentVote)
end

--adds a vote to the current vote
function LydsPlayer.AddToCount()
	if (!LydsPlayer.HasCurrentVote()) then return end

	LydsPlayer.CurrentVote.Count = LydsPlayer.CurrentVote.Count + 1

	if (LydsPlayer.IsSettingTrue("announce_count")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMediaPlayerMessage("Votes +1 to " .. LydsPlayer.CurrentVote.Type .. " (" .. LydsPlayer.CurrentVote.Count ..  " / " .. LydsPlayer.CurrentVote.Required  .. ")")
		end

		if (LydsPlayer.HasPassed() ) then
			LydsPlayer.CurrentVote.OnSuccess()
			LydsPlayer.CurrentVote = {}
			LydsPlayer.BroadcastEndVote()
			return
		end
	end

	LydsPlayer.BroadcastVote()
end

--starts a vote by copying a new vote from the votes table and then executing that vote
function LydsPlayer.StartVote(vote, ply)
	if ( !LydsPlayer.Votes[vote]) then return end

	local v = table.Copy(LydsPlayer.Votes[vote])

	local count = table.Count( player.GetAll() )

	if (v.Required > count ) then ply:SendMediaPlayerMessage("Must have at over " .. v.Required .. " players in the server for this vote, there is currently " .. count) return end

	if (v.Required == 1 ) then
		v.Required = math.Round(count / 2)
	else
		v.Required = count - math.floor(count / v.Required)
	end

	if (v.OnStart != nil ) then
		local result = v.OnStart()

		if (result == false ) then
			ply:SendMediaPlayerMessage("Unable to start vote")
			return
		end
	end

	local setting = LydsPlayer.GetSetting("vote_default_duration") or { Value = 10 }

	v.Owner = ply
	v.StartTime = CurTime()
	v.Time = setting.Value
	v.CurrentVideo = LydsPlayer.CurrentVideo or {}

	LydsPlayer.ExecuteVote(v)
end

--executes a vote, takes a table
function LydsPlayer.ExecuteVote(vote)
	if (!LydsPlayer.Votes[vote.Type]) then return end
	if (LydsPlayer.CurrentVote.Type == vote.Type ) then return end
	LydsPlayer.CurrentVote = vote

	local count = #player.GetAll()

	if (count == 1) then
		vote.OnSuccess()
		LydsPlayer.CurrentVote = {}
		return
	end

	if (LydsPlayer.IsSettingTrue("announce_vote")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMediaPlayerMessage("A vote has been initiated. type !vote to participate! " .. vote.Required .. " votes are required for this to pass!")
		end
	end

	LydsPlayer.BroadcastVote()

	timer.Simple(vote.Time, function()

		if (table.IsEmpty(LydsPlayer.CurrentVideo) ) then
			LydsPlayer.BroadcastEndVote()
			return
		end

		if (LydsPlayer.CurrentVideo == nil or table.IsEmpty(LydsPlayer.CurrentVideo) ) then return end

		if (vote.CurrentVideo != nil and !table.IsEmpty(vote.CurrentVideo) and (vote.CurrentVideo.Video != LydsPlayer.CurrentVideo.Video) ) then
			return
		end

		if (LydsPlayer.HasPassed()) then
			vote.OnSuccess()
		else
			vote.OnFailire()
		end

		LydsPlayer.CurrentVote = {}
		LydsPlayer.BroadcastEndVote()
	end)
end

--returns true if a vote has passed
function LydsPlayer.HasPassed()

	if (!LydsPlayer.HasCurrentVote()) then return false end
	if (LydsPlayer.CurrentVote.Count == 0 ) then return false end
	if (LydsPlayer.CurrentVote.Count != LydsPlayer.CurrentVote.Required ) then return false end

	return true
end
