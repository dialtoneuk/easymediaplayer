--Creates a warning box
function LydsPlayer.CreateWarningBox(title, message, timeout)
	timeout = timeout or false

	LydsPlayer.ReinstantiatePanel("WarningBox")
	LydsPlayer.GetPanel("WarningBox"):SetWarning(title, message, timeout)
end

--Creates a success box
function LydsPlayer.CreateSuccessBox(title, message, timeout)
	timeout = timeout or false

	LydsPlayer.ReinstantiatePanel("SuccessBox")
	LydsPlayer.GetPanel("SuccessBox"):SetBox(title, message, timeout)
end


--Creates a option box
function LydsPlayer.CreateOptionBox(title, message, callback)
	callback = callback or function(res) end

	if (type(callback) != "function") then
		error("callback must be a function with one argument")
	end

	LydsPlayer.ReinstantiatePanel("OptionBox")
	LydsPlayer.GetPanel("OptionBox"):SetBox(title, message)
	LydsPlayer.GetPanel("OptionBox"):SetCallback(callback)
end


function LydsPlayer.CreateChatMessage(msg, tag)
	msg = msg or " null "
	tag = tag or false
	msg = string.Trim(msg)
	local setting = LydsPlayer.GetSetting("chat_colours")

	if (tag) then
		chat.AddText( setting.Value.PrefixColor, "[" .. LydsPlayer.Name .. "] ", setting.Value.TextColor, LydsPlayer.AddFullStop(msg) )
	else
		chat.AddText( setting.Value.TextColor, msg )
	end

	chat.PlaySound()
end

--gets a setting icon
function LydsPlayer.GetSettingIcon(key, admin)
	local i
	if (admin) then

		for k,typ in pairs(LydsPlayer.AdminSettings) do
			if (k != key ) then continue end
			for _v,val in pairs(typ) do
				if (val.Icon != nil ) then
					return val.Icon
				end
			end
		end

		--TODO: CLEAN UP THIS FUCKING MESS GOOD GOD
		if ( string.find(key, "_key")) then
			i = "icon16/key.png"
		elseif ( string.find(key, "admin_") ) then
			i = "icon16/shield.png"
		elseif ( string.find(key, "youtube_")) then
			i = "icon16/television.png"
		elseif ( string.find(key, "dailymotion_")) then
			i = "icon16/film.png"
		elseif ( string.find(key, "mp3_")) then
			i = "icon16/world.png"
		elseif ( string.find(key, "player_")) then
			i = "icon16/user.png"
		elseif ( string.find(key, "playlist_")) then
			i = "icon16/report.png"
		elseif ( string.find(key, "tips_")) then
			i = "icon16/help.png"
		elseif ( string.find(key, "soundcloud_")) then
			i = "icon16/sound.png"
		elseif ( string.find(key, "pointshop_")) then
			i = "icon16/money.png"
		elseif ( string.find(key, "cooldown")) then
			i = "icon16/clock.png"
		elseif ( string.find(key, "announce")) then
			i = "icon16/email.png"
		elseif ( string.find(key, "commands")) then
			i = "icon16/text_bold.png"
		end
	else

		if (LydsPlayer.GetSetting(key).Icon != nil ) then
			return LydsPlayer.GetSetting(key).Icon
		end

		--TODO: FIND LESS RETARDED WAY
		if (string.find(key,"_colours")) then
			i = "icon16/color_wheel.png"
		elseif ( string.find(key, "_size")) then
			i = "icon16/layout.png"
		elseif ( string.find(key, "_position")) then
			i = "icon16/arrow_in.png"
		elseif ( string.find(key, "_resize")) then
			i = "icon16/arrow_refresh.png"
		elseif ( string.find(key, "_options")) then
			i = "icon16/page_edit.png"
		elseif ( string.find(key, "_volume")) then
			i = "icon16/sound.png"
		elseif ( string.find(key, "_key")) then
			i = "icon16/key.png"
		elseif ( string.find(key, "_centered")) then
			i = "icon16/text_align_center.png"
		elseif ( string.find(key, "_hide")) then
			i = "icon16/zoom.png"
		elseif ( string.find(key, "_show")) then
			i = "icon16/eye.png"
		end
	end

	return i
end

--sends a request to search youtube
function LydsPlayer.YoutubeSearch(query)

	if (query == nil or query == "") then return end

	net.Start("LydsPlayer.SearchQuery")
		net.WriteString(query)
		net.WriteString(LydsPlayer.MediaType.YOUTUBE)
	net.SendToServer()
end

--gets the admin settings
function LydsPlayer.GetAdminSettings()
	if (!LydsPlayer.LocalPlayer:IsAdmin()) then return end

	net.Start("LydsPlayer.RequestAdminSettings")
	--nothing
	net.SendToServer()
end

--sets the admin settings
function LydsPlayer.SetAdminSettings()
	if (!LydsPlayer.LocalPlayer:IsAdmin()) then return end
	if (table.IsEmpty(LydsPlayer.AdminSettings)) then return end

	net.Start("LydsPlayer.SetAdminSettings")
		net.WriteTable(LydsPlayer.AdminSettings)
	net.SendToServer()
end