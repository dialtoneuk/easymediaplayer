--Creates a warning box
function MediaPlayer.CreateWarningBox(title, message, timeout)
	timeout = timeout or false

	MediaPlayer.ReinstantiatePanel("WarningBox")
	MediaPlayer.GetPanel("WarningBox"):SetWarning(title, message, timeout)
end

--Creates a success box
function MediaPlayer.CreateSuccessBox(title, message, timeout)
	timeout = timeout or false

	MediaPlayer.ReinstantiatePanel("SuccessBox")
	MediaPlayer.GetPanel("SuccessBox"):SetBox(title, message, timeout)
end

function MediaPlayer.CreateChatMessage(msg)
	msg = msg or " null "
	local setting = MediaPlayer.GetSetting("chat_colours")

	chat.AddText( setting.Value.PrefixColor, "[" .. MediaPlayer.Name .. "] ", setting.Value.TextColor, MediaPlayer.AddFullStop(msg) )
	chat.PlaySound()
end

--gets a setting icon
function MediaPlayer.GetSettingIcon(key, admin)
	local i
	if (admin) then

		for k,typ in pairs(MediaPlayer.AdminSettings) do
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
		elseif ( string.find(key, "admin") ) then
			i = "icon16/shield.png"
		end
	else

		if (MediaPlayer.GetSetting(key).Icon != nil ) then
			return MediaPlayer.GetSetting(key).Icon
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
function MediaPlayer.YoutubeSearch(query)

	if (query == nil or query == "") then return end

	net.Start("MediaPlayer.SearchQuery")
		net.WriteString(query)
		net.WriteString(MediaPlayer.MediaType.YOUTUBE)
	net.SendToServer()
end

--gets the admin settings
function MediaPlayer.GetAdminSettings()
	if (!MediaPlayer.LocalPlayer:IsAdmin()) then return end

	net.Start("MediaPlayer.RequestAdminSettings")
	--nothing
	net.SendToServer()
end

--sets the admin settings
function MediaPlayer.SetAdminSettings()
	if (!MediaPlayer.LocalPlayer:IsAdmin()) then return end
	if (table.IsEmpty(MediaPlayer.AdminSettings)) then return end

	net.Start("MediaPlayer.SetAdminSettings")
		net.WriteTable(MediaPlayer.AdminSettings)
	net.SendToServer()
end