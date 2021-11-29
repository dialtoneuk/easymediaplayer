
--default hardcoded tips
LydsPlayer.Tips = {
	{
		body = "Admins can use {chatcommand_prefix}admin to remove videos from the blacklist.",
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
		body = "You can search for a video by typing {chatcommand_prefix}play or by typing {chatcommand_prefix}search into chat.",
	},
	{
		body = LydsPlayer.Name .. " was created by " .. LydsPlayer.Credits.Author,
	},
	{
		body = "You can use {chatcommand_prefix}like or {chatcommand_prefix}dislike to engage with the current video!"
	},
	{
		body = "You can vote to skip a video through using {chatcommand_prefix}voteskip",
	},
	{
		body = "You can vote to ban a video by using {chatcommand_prefix}voteban or {chatcommand_prefix}voteblacklist",
	},
	{
		body = "You can change the position of elements, colours and functionality by using {chatcommand_prefix}settings",
	},
	{
		body = "You can mute the current video with {chatcommand_prefix}mute",
	}
}

--load our custom tips
function LydsPlayer.LoadCustomTips()

	if ( LydsPlayer.GetSetting("tips_custom") == nil ) then
		return
	end

	local tip = LydsPlayer.GetSetting("tips_custom")

	if (tip.Type != LydsPlayer.Type.TABLE ) then
		errorBad("invalid type")
	end

	for k,v in pairs(tip.Value) do
		table.ForceInsert(LydsPlayer.Tips, {
			body = v
		})
	end
end

--selects a tip, first argument will display admin tips if true
function LydsPlayer.SelectTip(is_admin)
	is_admin = is_admin or false
	local tip = {}
	local count = 5;

	while (true) do

		if (count <= 0 ) then
			errorBad("failed to select tip")
		end

		local result = LydsPlayer.Tips[math.random( 1, #LydsPlayer.Tips )]

		if (result.admin != nil && result.admin != is_admin) then
			count = count - 1;
			continue;
		end

		tip = result;
		break;
	end
	return tip;
end

--parses a tips body and adds settings values or evaluates the string
function LydsPlayer.ParseTipBody(tip)
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

		local setting = LydsPlayer.GetSetting( capture ) or { Value = "null", Type = LydsPlayer.Type.STRING }
		if (LydsPlayer.Type == LydsPlayer.Type.TABLE ) then
			str = string.Replace(str, "{" .. capture .. "}", "invalid setting: table referenced" )
		else
			str = string.Replace(str, "{" .. capture .. "}", setting.Value )
		end
	end

	return str
end

--display the tip each frequency interval
function LydsPlayer.DisplayTip()

	if ( LydsPlayer.IsSettingTrue("tips_enabled")) then
		for k,v in pairs(player.GetAll()) do
			local tip = LydsPlayer.SelectTip(v:IsAdmin())

			if (tip != nil) then
				v:SendMediaPlayerMessage("psst - " .. LydsPlayer.ParseTipBody(tip))
			end
		end
	end

	timer.Create("LydsPlayer.Tips", LydsPlayer.GetSetting("tips_frequency").Value, 1, function()
		if ( LydsPlayer.GetSetting("tips_enabled").Value) then
			LydsPlayer.DisplayTip()
		end
	end)
end