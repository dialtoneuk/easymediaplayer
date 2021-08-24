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

--sends a request to search youtube
function MediaPlayer.YoutubeSearch(query)

	if (query == nil or query == "") then return end

	net.Start("MediaPlayer.SearchQuery")
	net.WriteString(query)
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