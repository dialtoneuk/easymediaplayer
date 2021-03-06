--chat commands global table
LydsPlayer.Commands = LydsPlayer.Commands or {}

--base commmand
LydsPlayer.BaseCommand = {
	Command = "default",
	Cooldown = true,
	Admin = false,
	Aliases = {

	},
	OnExecute = function(ply, command)
		--called when executed
	end
}

--registered commands
LydsPlayer.RegisteredCommands = {

	--this is also registered a a command so !voteskip
	VoteSkip = {
		Cooldown = false,
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_start_vote" .. " VoteSkip")
		end,
		Aliases = {
			"vs"
		}
	},
	VoteBlacklist = {
		Cooldown = false,
		OnExecute = function(ply, cmd)

			--see sv_media.lua for where this function is located, VoteBlacklist refers to the vote name defined in
			--sv_media_voting.lua
			ply:ConCommand("media_start_vote" .. " VoteBlacklist")
		end,
		Aliases = {
			"voteban",
			"vb"
		}
	},
	Vote = {
		OnExecute = function(ply, cmd)

			if (!LydsPlayer.HasCurrentVote() ) then return end

			if (!ply:GetNWBool("LydsPlayer.Voted")) then
				LydsPlayer.AddToCount()
				ply:SetNWBool("LydsPlayer.Voted", true )
			else
				ply:SendMediaPlayerMessage("You have already voted in this vote!")
			end
		end,
		Aliases = {
			"v"
		}
	},
	Search = {
		OnExecute = function(ply, cmd)
			ply:ConCommand("search_panel")
		end
	},
	Settings = {
		OnExecute = function(ply, cmd)
			ply:ConCommand("settings")
		end,
		Aliases = {
			"s"
		}
	},
	Refresh = {
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_create_cl")
		end
	},
	Like = {
		OnExecute = function(ply, cmd)
			if ( table.IsEmpty(LydsPlayer.CurrentVideo) ) then

				ply:SendMediaPlayerMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown

			ply:ConCommand("media_like_video")
		end
	},
	Dislike = {
		OnExecute = function(ply, cmd)
			if ( table.IsEmpty(LydsPlayer.CurrentVideo) ) then

				ply:SendMediaPlayerMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown

			ply:ConCommand("media_dislike_video")
		end
	},
	Mute = {
		OnExecute = function(ply, cmd)

			if ( table.IsEmpty(LydsPlayer.CurrentVideo) ) then

				ply:SendMediaPlayerMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown


			ply:ConCommand("media_mute_video");
		end,
		Aliases = {
			"m",
			"u",
			"unmute"
		},
	},
	Blacklist = {
		Admin = true,
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_blacklist_video")
		end
	},
	Skip = {
		Admin = true,
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_skip_video")
		end
	},
	Admin = {
		Admin = true,
		OnExecute = function(ply, cmd)
			ply:ConCommand("admin_panel")
		end
	}
}

--loads our chat commands
function LydsPlayer.LoadChatCommands()

	--this is the hook you would attach your shit too
	hook.Call("LydsPlayer.PreloadRegisteredCommands")

	for k,v in pairs(LydsPlayer.RegisteredCommands) do
		v = table.Merge(LydsPlayer.GetNewChatCommand(), v)

		v.Command = string.lower(k)

		if (v.Aliases != nil ) then

			for _,alias in pairs(v.Aliases) do
				local tab = table.Merge(table.Copy(v), {
					Command = string.lower(alias)
				})

				v.Aliases = {}
				LydsPlayer.AddChatCommand(tab)
			end
		end

		LydsPlayer.AddChatCommand(v)
	end

	hook.Call("LydsPlayer.CommandsLoaded")
end

--takes an array and adds commands to be registered to the global table
function LydsPlayer.AddRegisteredCommands(tab)

	for k,v in pairs(tab) do

		if (LydsPlayer.RegisteredCommands[k] != nil ) then
			warning(k .. " is an already registered command")
		end

		LydsPlayer.RegisteredCommands[k] = v
	end
end

--gets a new chat command which is used in the register functions
function LydsPlayer.GetNewChatCommand()
	return table.Copy(LydsPlayer.BaseCommand)
end

--adds the command for use in the main global table
function LydsPlayer.AddChatCommand(command)
	LydsPlayer.Commands[command.Command] = command
end

--parses a command given through the PlayerSay hook and matches it to one of our registered commands
--TODO: Add variable argument parsing for !play
function LydsPlayer.ParseCommand(ply, str)
	if (str.sub(str, 1,1) != LydsPlayer.GetSetting("chatcommand_prefix").Value ) then return false end

	local command = str.sub(str, 2 )
	command = str.Trim(command, " ")

	if (command == nil or command == "" ) then return false end
	if (str.len(command) > 32) then return false end

	if (str.find(command, " ")) then
		command = str.Explode(" ", command)[1]
		ply:SendMediaPlayerMessage("Commands with spaces not supported! Will treat your command like '" .. command .. "'" )
	end

	if (!LydsPlayer.Commands[command]) then ply:SendMediaPlayerMessage("command '" .. command .. "' does not exist") return false end

	command = LydsPlayer.Commands[command]

	if (!ply:IsAdmin() and command.Admin ) then return false end
	if (!command.OnExecute) then return false end

	if (command.Cooldown and LydsPlayer.HasCooldown(ply, "Command")) then
		ply:SendMediaPlayerMessage("You are doing that too quickly!")
		return nil
	else

		local result = command.OnExecute(ply, command)

		if (result != false and command.Admin == false ) then
			LydsPlayer.AddPlayerCooldown( ply, LydsPlayer.CopyCooldown("Command"))
		end

		return true
	end
end