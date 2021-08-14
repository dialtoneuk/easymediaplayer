
--[[
	Syntax
		You can use {SETTING_NAME} to get the value of a setting, it can't be a table though!
--]]

--default harcoded tips
MEDIA.Tips = {
	{
		body = "Admins can use {media_command_prefix}admin to remove videos from the blacklist.",
		admin = true
	},
	{
		body = "As an admin, Your server convars are synced with settings values automatically on each map load.",
		admin = true
	},
	{
		body = "As an admin, You can use !skip to skip the current video, and !blacklist to blacklist it",
		admin = true
	},
	{
		body = "You can search for a video by typing {media_command_prefix}play or by typing {media_command_prefix}search into chat.",
	},
	{
		body = MEDIA.Name .. " was created by " .. MEDIA.Credits.Author,
	},
	{
		body = "You can use {media_command_prefix}like or {media_command_prefix}dislike to engage with the current video!"
	},
	{
		body = "You can vote to skip a video through using {media_command_prefix}voteskip",
	},
	{
		body = "You can vote to ban a video by using {media_command_prefix}voteban or {media_command_prefix}voteblacklist",
	},
	{
		body = "You can change the position of elements, colours and functionality by using {media_command_prefix}settings",
	},
	{
		body = "You can mute the current video with {media_command_prefix}mute",
	}
}

--[[
	Loads our custom tips
--]]

function MEDIA.LoadCustomTips()

	if ( MEDIA.GetSetting("media_custom_tips") == nil ) then
		return
	end

	local tip = MEDIA.GetSetting("media_custom_tips")

	if (tip.Type != MEDIA.SettingTypes.TABLE ) then
		error("invalid type")
	end

	for k,v in pairs(tip.Value) do
		table.ForceInsert(MEDIA.Tips, {
			body = v
		})
	end
end

--[[

--]]

function MEDIA.SelectTip(is_admin)
	is_admin = is_admin or false
	local tip = {}
	local count = 5;

	while (true) do

		if (count <= 0 ) then
			error("failed to select tip")
			break
		end

		local result = MEDIA.Tips[math.random( 1, #MEDIA.Tips )]

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

function MEDIA.ParseTipBody(tip)
	local str = tip;

	if (type(tip) == "table") then
		if (tip.body == nil) then
			error("invalid")
			return nil
		end

		str = tip.body
	elseif (type(tip) != "string") then
		error("invalid")
		return nil
	end

	for capture in string.gmatch(str, "%{(.-)%}") do
		capture = string.lower(capture)

		local setting = MEDIA.GetSetting( capture ) or { Value = "null", Type = MEDIA.Type.STRING }
		if (MEDIA.Type == MEDIA.Type.TABLE ) then
			str = string.Replace(str, "{" .. capture .. "}", "invalid setting: table referenced" )
		else
			str = string.Replace(str, "{" .. capture .. "}", setting.Value )
		end
	end

	return str
end

--[[

--]]

function MEDIA.DisplayTip()

	if ( MEDIA.GetSetting("media_tips_enabled").Value) then
		for k,v in pairs(player.GetAll()) do
			local tip = MEDIA.SelectTip(v:IsAdmin())

			if (tip != nil) then
				v:SendMessage("psst - " .. MEDIA.ParseTipBody(tip))
			end
		end
	end

	timer.Create("MEDIA.Tips", MEDIA.GetSetting("media_tips_frequency").Value, 1, function()
		if ( MEDIA.GetSetting("media_tips_enabled").Value) then
			MEDIA.DisplayTip()
		end
	end)
end