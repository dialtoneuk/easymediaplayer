
--[[
	Syntax
		You can use {SETTING_NAME} to get the value of a setting, it can't be a table though!
--]]

--default harcoded tips
MediaPlayer.Tips = {
	{
		body = "Admins can use {MediaPlayer_command_prefix}admin to remove videos from the blacklist.",
		admin = true
	},
	{
		body = "Convars values overwrite settings values ever few minutes",
		admin = true
	},
	{
		body = "As an admin, You can use !skip to skip the current video, and !blacklist to blacklist it",
		admin = true
	},
	{
		body = "You can search for a video by typing {MediaPlayer_command_prefix}play or by typing {MediaPlayer_command_prefix}search into chat.",
	},
	{
		body = MediaPlayer.Name .. " was created by " .. MediaPlayer.Credits.Author,
	},
	{
		body = "You can use {MediaPlayer_command_prefix}like or {MediaPlayer_command_prefix}dislike to engage with the current video!"
	},
	{
		body = "You can vote to skip a video through using {MediaPlayer_command_prefix}voteskip",
	},
	{
		body = "You can vote to ban a video by using {MediaPlayer_command_prefix}voteban or {MediaPlayer_command_prefix}voteblacklist",
	},
	{
		body = "You can change the position of elements, colours and functionality by using {MediaPlayer_command_prefix}settings",
	},
	{
		body = "You can mute the current video with {MediaPlayer_command_prefix}mute",
	}
}

--[[
	Loads our custom tips
--]]

function MediaPlayer.LoadCustomTips()

	if ( MediaPlayer.GetSetting("MediaPlayer_custom_tips") == nil ) then
		return
	end

	local tip = MediaPlayer.GetSetting("MediaPlayer_custom_tips")

	if (tip.Type != MediaPlayer.SettingTypes.TABLE ) then
		errorBad("invalid type")
	end

	for k,v in pairs(tip.Value) do
		table.ForceInsert(MediaPlayer.Tips, {
			body = v
		})
	end
end

--[[

--]]

function MediaPlayer.SelectTip(is_admin)
	is_admin = is_admin or false
	local tip = {}
	local count = 5;

	while (true) do

		if (count <= 0 ) then
			errorBad("failed to select tip")
		end

		local result = MediaPlayer.Tips[math.random( 1, #MediaPlayer.Tips )]

		if (result.admin != nil && result.admin != is_admin) then
			count = count - 1;
			continue;
		end

		tip = result;
		break;
	end
	return tip;
end

--[[

--]]

function MediaPlayer.ParseTipBody(tip)
	local str = tip;

	if (type(tip) == "table") then
		if (tip.body == nil) then
			errorBad("invalid")
		end

		str = tip.body
	elseif (type(tip) != "string") then
		errorBad("invalid")
	end

	for capture in string.gmatch(str, "%{(.-)%}") do
		capture = string.lower(capture)

		local setting = MediaPlayer.GetSetting( capture ) or { Value = "null", Type = MediaPlayer.Type.STRING }
		if (MediaPlayer.Type == MediaPlayer.Type.TABLE ) then
			str = string.Replace(str, "{" .. capture .. "}", "invalid setting: table referenced" )
		else
			str = string.Replace(str, "{" .. capture .. "}", setting.Value )
		end
	end

	return str
end

--[[

--]]

function MediaPlayer.DisplayTip()

	if ( MediaPlayer.IsSettingTrue("MediaPlayer_tips_enabled")) then
		for k,v in pairs(player.GetAll()) do
			local tip = MediaPlayer.SelectTip(v:IsAdmin())

			if (tip != nil) then
				v:SendMessage("psst - " .. MediaPlayer.ParseTipBody(tip))
			end
		end
	end

	timer.Create("MediaPlayer.Tips", MediaPlayer.GetSetting("MediaPlayer_tips_frequency").Value, 1, function()
		if ( MediaPlayer.GetSetting("MediaPlayer_tips_enabled").Value) then
			MediaPlayer.DisplayTip()
		end
	end)
end