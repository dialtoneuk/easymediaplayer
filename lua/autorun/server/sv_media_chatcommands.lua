--[[
	Our chat commands!
--]]

MEDIA.Commands = MEDIA.Commands or {
	_ChatCommand = {
		Command = "default",
		Cooldown = true,
		Admin = false,
		OnExecute = function(ply, command)
			--called when executed
		end
	}
}

--[[
	Chat Commands
	Devs: You can add to these!

	TODO: Argument parging for !play <url> command
---------------------------------------------------------------------------
--]]

function MEDIA.LoadChatCommands()

	--Vote skip
	local command = MEDIA.NewChatCommand()
	command.Command = "voteskip" --!voteskip
	command.Admin = false
	command.Cooldown = false
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_start_vote" .. " VoteSkip")
	end

	MEDIA.AddChatCommand(command)

	--Vote Blacklist
	command = MEDIA.NewChatCommand()
	command.Command = "voteblacklist"
	command.Admin = false
	command.Cooldown = false
	command.OnExecute = function(ply, cmd)

		--see sv_media.lua for where this function is located, VoteBlacklist refers to the vote name defined in
		--sv_media_voting.lua
		ply:ConCommand("media_start_vote" .. " VoteBlacklist")
	end

	MEDIA.AddChatCommand(command)

	--Alt command
	command.Command = "voteban"
	MEDIA.AddChatCommand(command)

	--Vote
	command = MEDIA.NewChatCommand()
	command.Command = "vote"
	command.Admin = false
	command.OnExecute = function(ply, cmd)

		if (!MEDIA.HasCurrentVote() ) then return end

		if (!ply:GetNWBool("Voted")) then
			MEDIA.AddToCount()
			ply:SetNWBool("Voted", true )
		else
			ply:SendMessage("You have already voted in this vote!")
		end
	end

	MEDIA.AddChatCommand(command)

	--Search Command
	command = MEDIA.NewChatCommand()
	command.Command = "search"
	command.Admin = false
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_search_panel")
	end

	MEDIA.AddChatCommand(command)

	--alt command
	command.Command = "browser"
	MEDIA.AddChatCommand(command)

	--alt command
	command.Command = "s"
	MEDIA.AddChatCommand(command)

	command = MEDIA.NewChatCommand()
	command.Command = "play"
	command.Admin = false
	command.OnExecute = function(ply, cmd)

		--comand to parse command here
	end

	MEDIA.AddChatCommand(command)

	--Settings Panel
	command = MEDIA.NewChatCommand()
	command.Command = "settings"
	command.Admin = false
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_settings")
	end

	MEDIA.AddChatCommand(command)

	--Like a video
	command = MEDIA.NewChatCommand()
	command.Command = "like"
	command.Admin = false
	command.OnExecute = function(ply, cmd)
		if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

			ply:SendMessage("No video currently playing!")
			return false
		end --returning false won't inhibit a cooldown

		ply:ConCommand("media_like_video")
	end

	MEDIA.AddChatCommand(command)

	--DisLike a video
	command = MEDIA.NewChatCommand()
	command.Command = "dislike"
	command.Admin = false
	command.OnExecute = function(ply, cmd)
		if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

			ply:SendMessage("No video currently playing!")
			return false
		end --returning false won't inhibit a cooldown

		ply:ConCommand("media_dislike_video")
	end

	MEDIA.AddChatCommand(command)

	--Mute the video
	command = MEDIA.NewChatCommand()
	command.Command = "mute"
	command.Admin = false
	command.OnExecute = function(ply, cmd)

		if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

			ply:SendMessage("No video currently playing!")
			return false
		end --returning false won't inhibit a cooldown

		if (MEDIA.GetSeting("media_mute_video").Value == 1 ) then
			MEDIA.ChangeClientSetting("media_mute_video", 0 );
			ply:SendMessage("Video unmuted")
		else
			MEDIA.ChangeClientSetting("media_mute_video", 1 );
			ply:SendMessage("Video muted")
		end

		ply:RunConsoleCommand("media_create_cl");
	end

	MEDIA.AddChatCommand(command)

	--Easy way of copying a chat command
	command.Command = "unmute"
	MEDIA.AddChatCommand(command)

	--Admin blacklist video
	command = MEDIA.NewChatCommand()
	command.Command = "blacklist"
	command.Admin = true
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_blacklist_video")
	end

	MEDIA.AddChatCommand(command)

	--Admin skip
	command = MEDIA.NewChatCommand()
	command.Command = "skip"
	command.Admin = true
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_skip_video")
	end

	MEDIA.AddChatCommand(command)

	--Admin blacklist command Panel
	command = MEDIA.NewChatCommand()
	command.Command = "admin"
	command.Admin = true
	command.OnExecute = function(ply, cmd)
		ply:ConCommand("media_admin_panel")
	end

	MEDIA.AddChatCommand(command)
end

--[[
	Returns a new chat command table
--]]

function MEDIA.NewChatCommand()
	return table.Copy(MEDIA.Commands._ChatCommand)
end

--[[
	Adds a chat command
--]]

function MEDIA.AddChatCommand(command)

	if (command == "_ChatCommand") then
		error("cannot be _ChatCommand")
	end

	MEDIA.Commands[command.Command] = command
end

--[[
	Parses a command and then executes the command
--]]

function MEDIA.ParseCommand(ply, string)
	if (string.sub(string, 1,1) != MEDIA.GetSetting("media_command_prefix").Value ) then return false end

	local command = string.sub(string, 2 )
	command = string.Trim(command, " ")

	if (command == nil or command == "" ) then return false end
	if (string.len(command) > 32) then return false end

	if (string.find(command, " ")) then
		command = string.Explode(" ", command)[1]
		ply:SendMessage("Commands with spaces not supported! Will treat your command like '" .. command .. "'" )
	end

	if (!MEDIA.Commands[command]) then ply:SendMessage("command '" .. command .. "' does not exist") return false end

	command = MEDIA.Commands[command]

	if (!ply:IsAdmin() and command.Admin ) then return false end
	if (!command.OnExecute) then return false end

	if (command.Cooldown and MEDIA.HasCooldown(ply, "Command")) then
		ply:SendMessage("You are doing that too quickly!")
		return nil
	else

		local result = command.OnExecute(ply, command)

		if (result != false and command.Admin == false ) then
			MEDIA.AddPlayerCooldown( ply, MEDIA.GetNewCooldown("Command"))
		end

		return true
	end
end

--hook call
hook.Run("MEDIA_LoadedChatCommands")
