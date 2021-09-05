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

--registered votes
MediaPlayer.RegisteredVotes = {
	--this is the type of vote and what we'll use to grab this vote
	VoteSkip = {
		Time = 30,
		OnSuccess = function()
			MediaPlayer.SkipVideo()

			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Vote Passed! Skipping video..")
			end
		end,
		OnFailire = function()
			for k,v in pairs(player.GetAll()) do
				v:SendMediaPlayerMessage("Vote has not been skipped!")
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
function MediaPlayer.LoadVotes()

	hook.Call("MediaPlayer.PreloadRegisteredVotes")

	for k,v in pairs(MediaPlayer.RegisteredVotes) do
		v = table.Merge(MediaPlayer.GetNewVote(), table.Copy(v))
		v.Type = k
		v.Required = v.Required

		--register it
		MediaPlayer.RegisterVote(v)
	end

	--called after votes are loaded
	hook.Run("MediaPlayer.VotesLoaded")
end

--adds a new vote to be loaded
function MediaPlayer.AddRegisteredVotes(tab)

	for k,v in pairs(tab) do

		if (MediaPlayer.RegisteredVotes[k] != nil ) then
			warning(k .. " is an already registered vote")
		end

		MediaPlayer.RegisteredVotes[k] = v
	end
end

--returns a copy of the base vote
function MediaPlayer.GetNewVote()
	return table.Copy(MediaPlayer.BaseVote)
end

--broadcasts the current vote to the server
function MediaPlayer.BroadcastVote()
	if (!MediaPlayer.HasCurrentVote()) then return end

	for k,v in pairs(player.GetAll()) do
		MediaPlayer.SendVoteToPlayer(v)
	end
end

--broadcsts the end of the vote
function MediaPlayer.BroadcastEndVote()
	for k,v in pairs(player.GetAll()) do
		v:SetNWBool("MediaPlayer.Voted", false )
		MediaPlayer.SendEndVoteToPlayer(v)
	end
end

--broadcasts a new vote to a player
function MediaPlayer.SendVoteToPlayer( ply )
	if (!MediaPlayer.HasCurrentVote()) then return end


	net.Start("MediaPlayer.NewVote")
		--remove the owner field
		local t = table.Copy(MediaPlayer.CurrentVote)

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
function MediaPlayer.SendEndVoteToPlayer( ply )
	net.Start("MediaPlayer.EndVote")
	net.Send(ply)
end

--adds a new kind of vote ready for use
function MediaPlayer.RegisterVote(vote)
	MediaPlayer.Votes[vote.Type] = vote
end

--gets that kind of vote
function MediaPlayer.GetKindOfVote(vote)
	if ( !MediaPlayer.Votes[vote]) then return end

	return MediaPlayer.Votes[vote]
end

--returns true if we havea current vote
function MediaPlayer.HasCurrentVote()
	return !table.IsEmpty(MediaPlayer.CurrentVote)
end

--adds a vote to the current vote
function MediaPlayer.AddToCount()
	if (!MediaPlayer.HasCurrentVote()) then return end

	MediaPlayer.CurrentVote.Count = MediaPlayer.CurrentVote.Count + 1

	if (MediaPlayer.IsSettingTrue("announce_count")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMediaPlayerMessage("Votes +1 to " .. MediaPlayer.CurrentVote.Type .. " (" .. MediaPlayer.CurrentVote.Count ..  " / " .. MediaPlayer.CurrentVote.Required  .. ")")
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

--starts a vote by copying a new vote from the votes table and then executing that vote
function MediaPlayer.StartVote(vote, ply)
	if ( !MediaPlayer.Votes[vote]) then return end

	local v = table.Copy(MediaPlayer.Votes[vote])

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

	local setting = MediaPlayer.GetSetting("vote_default_duration") or { Value = 10 }

	v.Owner = ply
	v.StartTime = CurTime()
	v.Time = setting.Value
	v.CurrentVideo = MediaPlayer.CurrentVideo or {}

	MediaPlayer.ExecuteVote(v)
end

--executes a vote, takes a table
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

	if (MediaPlayer.IsSettingTrue("announce_vote")) then
		for k,v in pairs(player.GetAll()) do
			v:SendMediaPlayerMessage("A vote has been initiated. type !vote to participate! " .. vote.Required .. " votes are required for this to pass!")
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
			return
		end

		if (MediaPlayer.HasPassed()) then
			vote.OnSuccess()
		else
			vote.OnFailire()
		end

		MediaPlayer.CurrentVote = {}
		MediaPlayer.BroadcastEndVote()
	end)
end

--returns true if a vote has passed
function MediaPlayer.HasPassed()

	if (!MediaPlayer.HasCurrentVote()) then return false end
	if (MediaPlayer.CurrentVote.Count == 0 ) then return false end
	if (MediaPlayer.CurrentVote.Count != MediaPlayer.CurrentVote.Required ) then return false end

	return true
end
