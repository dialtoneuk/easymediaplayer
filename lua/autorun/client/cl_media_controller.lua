--our shared global

function MEDIA.SetURL(url)
	MEDIA.URL = url
end

--[[
Search
*--]]

function MEDIA.SearchYoutube(query)

	if (query == nil or query == "") then return end

	net.Start("MEDIA_SearchQuery")
	net.WriteString(query)
	net.SendToServer()
end

--[[
Requests and then sets our admin settings if not already sent
--]]

function MEDIA.GetAdminSettings()
	if (!LocalPlayer():IsAdmin()) then return end

	net.Start("MEDIA_RequestAdminSettings")
	--nothing
	net.SendToServer()
end

--[[
Pushes a change to server settings
--]]

function MEDIA.SetAdminSettings()
	if (!LocalPlayer():IsAdmin()) then return end
	if (table.IsEmpty(MEDIA.AdminSettings)) then return end

	net.Start("MEDIA_SetAdminSettings")
	net.WriteTable(MEDIA.AdminSettings)
	net.SendToServer()
end

--[[
Create Settings
--]]

function MEDIA.CreateSettings()
	local admin = {}
	local setting = MEDIA.GetSetting("media_settings_size")

	if (LocalPlayer():IsAdmin()) then
		if (!MEDIA.AdminSettings) then
			MEDIA.GetAdminSettings()
			Derma_Message("Hello Admin~", "Please type !settings or media_settings again.", "Ok")
			return nil
		end
		admin = MEDIA.AdminSettings
	end

	if (MEDIA.SettingsPanel != nil) then MEDIA.SettingsPanel:Remove() end

	MEDIA.SettingsPanel = vgui.Create("MEDIA_Settings")
	MEDIA.SettingsPanel:SetHeight(setting.Value.Height or 500)
	MEDIA.SettingsPanel:SetWidth(setting.Value.Width or 500)
	MEDIA.SettingsPanel:MakePopup()
	MEDIA.SettingsPanel:Center()

	MEDIA.SettingsPanel:FillPropertySheet({
		Server = admin,
		Client = MEDIA.Settings
	})
end

--[[
Creates the Admin Panel
--]]

function MEDIA.CreateAdminPanel()

	if (MEDIA.AdminPanel != nil and IsValid(MEDIA.AdminPanel)) then
		MEDIA.AdminPanel:Remove()
	end

	MEDIA.AdminPanel = vgui.Create("MEDIA_Admin")

	local setting = MEDIA.GetSetting("media_admin_size")
	local width = setting.Value.Width or 500
	local height = setting.Value.Height or 500

	MEDIA.AdminPanel:SetSize(width, height)
	MEDIA.AdminPanel:SetDraggable(true)
	MEDIA.AdminPanel:MakePopup()
	MEDIA.AdminPanel:Center()

	MEDIA.AdminPanel.OnClose = function()
		MEDIA.AdminPanel:Hide()
	end

	local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0 }
	if (setting2.Value != 1) then
		MEDIA.AdminPanel:Hide()
	end
end

--[[
Creates the Search Panel
--]]

function MEDIA.CreateSearchPanel()

	if (MEDIA.SearchPanel != nil and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:Remove()
	end

	MEDIA.SearchPanel = vgui.Create("MEDIA_Search")

	local setting = MEDIA.GetSetting("media_search_size")
	local width = setting.Value.Width or 350
	local height = setting.Value.Height or 500

	MEDIA.SearchPanel:SetSize(width, height)
	MEDIA.SearchPanel:SetDraggable(true)

	MEDIA.SearchPanel.OnClose = function()
		MEDIA.SearchPanel:Hide()
	end

	local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0 }
	if (setting2.Value != 1) then
		MEDIA.SearchPanel:Hide()
	end
end

--[[
Creates the video
--]]

function MEDIA.CreatePlayerPanel()

	if (MEDIA.PlayerPanel != nil and IsValid(MEDIA.PlayerPanel)) then
		MEDIA.PlayerPanel:Remove()
	end

	MEDIA.PlayerPanel = vgui.Create("MEDIA_Player")

	local setting = MEDIA.GetSetting("media_player_size")
	local width = setting.Value.Width or 350
	local height = setting.Value.Height or 500

	MEDIA.PlayerPanel:SetSize(width, height)
	MEDIA.PlayerPanel:Reposition()

	if (!table.IsEmpty(MEDIA.CurrentVideo)) then
		MEDIA.PlayerPanel:SetVideo(MEDIA.CurrentVideo)
	else
		local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0 }
		local setting3 = MEDIA.GetSetting("media_player_hide") or { Value = 0 }

		if (setting2.Value != 1 and setting3.Value == 1 ) then
			MEDIA.PlayerPanel:Hide()
		end
	end
end

--[[
Creates the vote
--]]

function MEDIA.CreateVotePanel()

	if (MEDIA.VotePanel != nil and IsValid(MEDIA.VotePanel)) then
		MEDIA.VotePanel:Remove()
	end

	MEDIA.VotePanel = vgui.Create("MEDIA_Vote")

	local setting = MEDIA.GetSetting("media_all_show") or { Value = 0 }

	if (setting.Value != 1 ) then
		MEDIA.VotePanel:Hide()
	end

	setting = MEDIA.GetSetting("media_vote_size")

	local width = setting.Value.Width or 150
	local height = setting.Value.Height or 700

	MEDIA.VotePanel:SetPos( 10, 10 )
	MEDIA.VotePanel:SetSize(width, height)
end

--[[
Creates the playlist
--]]

function MEDIA.CreatePlaylistPanel()

	if (MEDIA.PlaylistPanel != nil and IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:Remove()
	end

	MEDIA.PlaylistPanel = vgui.Create("MEDIA_Playlist")

	local setting = MEDIA.GetSetting("media_playlist_size")
	local width = setting.Value.Width or 150
	local height = setting.Value.Height or 700

	MEDIA.PlaylistPanel:SetPos(ScrW() - (width + 10 ), 10 )
	MEDIA.PlaylistPanel:SetSize(width, height)
	MEDIA.PlaylistPanel:UpdatePlaylist()

	if (MEDIA.GetSetting("media_all_show").Value != 1 and MEDIA.GetSetting("media_playlist_hide").Value == 1 ) then
		MEDIA.PlaylistPanel:Hide()
	end
end
