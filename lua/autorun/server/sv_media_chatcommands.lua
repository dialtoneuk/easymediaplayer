--[[
	Our chat commands!
--]]

MEDIA.Commands = MEDIA.Commands or {}

--base commmand
MEDIA.BaseCommand = {
	Command = "default",
	Cooldown = true,
	Admin = false,
	Aliases = {

	},
	OnExecute = function(ply, command)
		--called when executed
	end
}

--[[
	Devs! You can add to this
]]--

MEDIA.RegisteredCommands = {

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

			if (!MEDIA.HasCurrentVote() ) then return end

			if (!ply:GetNWBool("Voted")) then
				MEDIA.AddToCount()
				ply:SetNWBool("Voted", true )
			else
				ply:SendMessage("You have already voted in this vote!")
			end
		end,
		Aliases = {
			"v"
		}
	},
	Search = {
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_search_panel")
		end
	},
	Settings = {
		OnExecute = function(ply, cmd)
			ply:ConCommand("media_settings")
		end,
		Aliases = {
			"s"
		}
	},
	Like = {
		OnExecute = function(ply, cmd)
			if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

				ply:SendMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown

			ply:ConCommand("media_like_video")
		end
	},
	Dislike = {
		OnExecute = function(ply, cmd)
			if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

				ply:SendMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown

			ply:ConCommand("media_dislike_video")
		end
	},
	Mute = {
		OnExecute = function(ply, cmd)

			if ( table.IsEmpty(MEDIA.CurrentVideo) ) then

				ply:SendMessage("No video currently playing!")
				return false
			end --returning false won't inhibit a cooldown

			if (MEDIA.GetSeting("media_mute_video").Value) then
				MEDIA.ChangeSetting("media_mute_video", false );
				ply:SendMessage("Video unmuted")
			else
				MEDIA.ChangeSetting("media_mute_video", true );
				ply:SendMessage("Video muted")
			end

			ply:RunConsoleCommand("media_create_cl");
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
			ply:ConCommand("media_admin_panel")
		end
	}
}

--[[
	Chat Commands
	Devs: You can add to these!

	TODO: Argument parsing for !play <url> command
---------------------------------------------------------------------------
--]]

function MEDIA.LoadChatCommands()

	hook.Call("MEDIA.PreloadRegisteredCommands")

	for k,v in pairs(MEDIA.RegisteredCommands) do
		v = table.Merge(MEDIA.GetNewChatCommand(), v)

		v.Command = string.lower(k)

		if (v.Aliases != nil ) then

			for _,alias in pairs(v.Aliases) do
				local tab = table.Merge(table.Copy(v), {
					Command = string.lower(alias)
				})

				v.Aliases = {}
				MEDIA.AddChatCommand(tab)
			end
		end

		MEDIA.AddChatCommand(v)
	end
end

function MEDIA.AddRegisteredCommands(tab)

	for k,v in pairs(tab) do

		if (MEDIA.RegisteredCommands[k] != nil ) then
			warning(k .. " is an already registered command")
		end

		MEDIA.RegisteredCommands[k] = v
	end
end

--[[
	Returns a new chat command table
--]]

function MEDIA.GetNewChatCommand()
	return table.Copy(MEDIA.BaseCommand)
end

--[[
	Adds a chat command
--]]

function MEDIA.AddChatCommand(command)
	MEDIA.Commands[command.Command] = command
end

--[[
	Parses a command and then executes the command
--]]

function MEDIA.ParseCommand(ply, str)
	if (str.sub(str, 1,1) != MEDIA.GetSetting("media_command_prefix").Value ) then return false end

	local command = str.sub(str, 2 )
	command = str.Trim(command, " ")

	if (command == nil or command == "" ) then return false end
	if (str.len(command) > 32) then return false end

	if (str.find(command, " ")) then
		command = str.Explode(" ", command)[1]
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
hook.Run("MEDIA.LoadedChatCommands")
