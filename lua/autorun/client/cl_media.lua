--player and playlist
MEDIA.CurrentVideo = MEDIA.CurrentVideo or {}
MEDIA.Playlist = MEDIA.Playlist or {}

--search stuff
MEDIA.History = MEDIA.History or {}
MEDIA.PlayerHistory = MEDIA.PlayerHistory or {}
MEDIA.SearchResults = MEDIA.SearchResults or {}

--admin stuff
MEDIA.Blacklist = MEDIA.Blacklist or {}

--For our history page
MEDIA.HistoryCount = MEDIA.HistoryCount or 1
MEDIA.HistoryPageMax = MEDIA.HistoryPageMax or 1

--for our player history page
MEDIA.PlayerHistoryCount = MEDIA.PlayerHistoryCount or 1
MEDIA.PlayerPageMax = MEDIA.PlayerPageMax or 1

/*
Fonts
-----------------------------------------------------------------------------
*/

surface.CreateFont( "BiggerText", {
	font = "Arial",
	extended = false,
	size = 30,
	weight = 200,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

surface.CreateFont( "BigText", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 200,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
})

surface.CreateFont( "MediumText", {
	font = "Arial",
	extended = false,
	size = 15,
	weight = 100,
	blursize = 0,
	scanlines = 1,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "SmallText", {
	font = "Arial",
	extended = false,
	size = 13,
	weight = 80,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

/*
Hooks
-----------------------------------------------------------------------------
*/

hook.Add("OnContextMenuOpen", "MEDIA_ContextMenu", function()
	local setting = MEDIA.GetSetting("media_playlist_show_in_context") or { Value = 1}
	if (MEDIA.PlaylistPanel and IsValid(MEDIA.PlaylistPanel)) then

		if (setting.Value == 1 and !MEDIA.PlaylistPanel:IsVisible()) then
			MEDIA.PlaylistPanel:Show()
		end

		MEDIA.PlaylistPanel:SetKeyboardInputEnabled(true)
		MEDIA.PlaylistPanel:SetMouseInputEnabled(true)
	end

	if (IsValid(MEDIA.PlayerPanel)) then
		MEDIA.PlayerPanel:MakePopup()
	end
end)

hook.Add("OnContextMenuClose", "MEDIA_ContextMenu", function()
	local setting = MEDIA.GetSetting("media_playlist_hide") or { Value = 1}
	local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0}

	if (MEDIA.PlaylistPanel and IsValid(MEDIA.PlaylistPanel)) then

		if ( MEDIA.PlaylistPanel:IsVisible() and setting.Value == 1 and setting2.Value == 0) then
			MEDIA.PlaylistPanel:Hide()
		end

		if (IsValid(MEDIA.PlaylistPanel)) then
			MEDIA.PlaylistPanel:SetKeyboardInputEnabled(false)
			MEDIA.PlaylistPanel:SetMouseInputEnabled(false)
		end

		if (IsValid(MEDIA.PlayerPanel)) then
			MEDIA.PlayerPanel:SetKeyboardInputEnabled(false)
			MEDIA.PlayerPanel:SetMouseInputEnabled(false)
		end
	end
end)

hook.Add("ScoreboardShow", "MEDIA_ScoreboardShow", function()
	local setting = MEDIA.GetSetting("media_playlist_hide") or { Value = 1}
	local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0}

	if (setting.Value == 1 and MEDIA.PlaylistPanel and !MEDIA.PlaylistPanel:IsVisible() and setting2.Value == 0) then
		MEDIA.PlaylistPanel:Show()
	end

	if (IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:MakePopup()
	end
end)

hook.Add("ScoreboardHide", "MEDIA_ScoreboardHide", function()
	local setting = MEDIA.GetSetting("media_playlist_hide") or { Value = 1}
	local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0}

	if (IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:SetKeyboardInputEnabled(false)
		MEDIA.PlaylistPanel:SetMouseInputEnabled(false)
	end

	if (setting.Value == 1 and MEDIA.PlaylistPanel and MEDIA.PlaylistPanel:IsVisible() and setting2.Value == 0) then
		MEDIA.PlaylistPanel:Hide()
	end
end)

/*
Console Commands
-----------------------------------------------------------------------------
*/

/*
Youtube search function
*/

concommand.Add("media_search", function (ply, cmd, args)

	if (args[1] == nil or args[1] == "" ) then return end
	MEDIA.SearchYoutube(args[1])
end)

/*
Creates all components
*/


concommand.Add("media_create_cl", function()
	MEDIA.CreateVotePanel()
	MEDIA.CreatePlayerPanel()
	MEDIA.CreatePlaylistPanel()
	MEDIA.CreateSearchPanel()
	if ( LocalPlayer():IsAdmin() ) then MEDIA.CreateAdminPanel() end
end)

/*
Shows our Search Panel
*/

concommand.Add("media_search_panel", function()
	if (MEDIA.SearchPanel and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:Show()
	end
end)

/*
Shows our Admin Panel
*/

concommand.Add("media_admin_panel", function()
	if (MEDIA.AdminPanel and IsValid(MEDIA.AdminPanel)) then
		MEDIA.AdminPanel:Show()
	end
end)

/*
Creates Search Panel
*/

concommand.Add("media_create_search_panel", function()
	MEDIA.CreateSearchPanel()
end)

/*
	Creates admin panel
*/


concommand.Add("media_create_admin_panel", function()
	MEDIA.CreateAdminPanel()
end)

/*
Creates Vote Panel
*/

concommand.Add("media_create_vote_panel", function()
	MEDIA.CreateVotePanel()
end)

/*
Creates Playlist Panel
*/

concommand.Add("media_create_player_panel", function()
	MEDIA.CreatePlayerPanel()
end)

/*
Creates Playlist Panel
*/

concommand.Add("media_create_playlist_panel", function()
	MEDIA.CreatePlaylistPanel()
end)

/*
Displays the media settings
*/

concommand.Add("media_settings",function()
	MEDIA.CreateSettings()
end)

/*
Net stuff
-----------------------------------------------------------------------------
*/

net.Receive("MEDIA_SendMessage", function()
	local msg = net.ReadString() or " null "
	local setting = MEDIA.GetSetting("media_chat_colours")

	chat.AddText( setting.Value.PrefixColor, "[" .. MEDIA.Name .. "] ", setting.Value.TextColor, msg )
	chat.PlaySound()
end)

/*
	This receives a chunk of history data AKA Paged data
*/

net.Receive("MEDIA_SendHistoryData", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MEDIA.History = tab
	MEDIA.HistoryCount = net.ReadFloat()
	MEDIA.HistoryPageMax = net.ReadFloat()

	--now, add it to the search panel
	if (MEDIA.SearchPanel and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:AddPageHeader(MEDIA.SearchPanel.HistoryGrid, MEDIA.SearchPanel.HistoryPage)
		MEDIA.SearchPanel:PresentHistory()
		MEDIA.SearchPanel.HistoryPage = MEDIA.SearchPanel.HistoryPage + 1
	end
end)

/*
Recieves personal history data from the server (basically checks for steam id before sending history)
*/

net.Receive("MEDIA_SendPersonalHistory", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MEDIA.PlayerHistory = tab
	MEDIA.PlayerHistoryCount = net.ReadFloat()
	MEDIA.PlayerHistoryPageMax = net.ReadFloat()

	--now, add it to the search panel
	if (MEDIA.SearchPanel and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:AddPageHeader(MEDIA.SearchPanel.PlayerHistoryGrid, MEDIA.SearchPanel.PlayerHistoryPage, MEDIA.PlayerHistoryCount)
		MEDIA.SearchPanel:PresentPlayerHistory()
		MEDIA.SearchPanel.PlayerHistoryPage = MEDIA.SearchPanel.PlayerHistoryPage + 1
	end
end)

/*
 This receives ALL data
  Note: not used atm
*/

net.Receive("MEDIA_SendHistory", function()
	MEDIA.History =  net.ReadTable()
	MEDIA.HistoryCount = net.ReadFloat()
	MEDIA.HistoryPageMax = net.ReadFloat()
	if (MEDIA.SearchPanel and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:RefreshHistoryGrid()
		MEDIA.SearchPanel:AddPageHeader(MEDIA.SearchPanel.HistoryGrid, "All History")
		MEDIA.SearchPanel:PresentHistory()
	end
end)

/*
Recieves history data from the server
*/

net.Receive("MEDIA_SendHistoryForVideo", function()
	local tab = net.ReadTable()
	MEDIA.History[tab.Video] = tab;
end)

/*
Recieves blacklist data from the server
*/

net.Receive("MEDIA_SendBlacklist", function()
	MEDIA.Blacklist = net.ReadTable()

	if (MEDIA.AdminPanel and IsValid(MEDIA.AdminPanel)) then
		MEDIA.AdminPanel:PresentBlacklist()
	end
end)

/*
Ends a new vote
*/

net.Receive("MEDIA_EndVote", function()
	MEDIA.CurrentVote = {}

	local setting = MEDIA.GetSetting("media_all_show") or { Value = 0}

	if (MEDIA.VotePanel and IsValid(MEDIA.VotePanel)) then
		MEDIA.VotePanel:Reset()
		if (	setting.Value != 1) then
			MEDIA.VotePanel:Hide()
		end
	end
end)

/*
Starts a new vote
*/

net.Receive("MEDIA_NewVote", function()
	MEDIA.CurrentVote = net.ReadTable()

	if (MEDIA.VotePanel and IsValid(MEDIA.VotePanel) ) then
		MEDIA.VotePanel:Show()
		MEDIA.VotePanel:SetVote(MEDIA.CurrentVote)
	end
end)

/*
Sets Search Data
*/

net.Receive("MEDIA_SendSearchResults",function()
	MEDIA.SearchResults = net.ReadTable()

	if (MEDIA.SearchPanel and IsValid(MEDIA.SearchPanel)) then
		MEDIA.SearchPanel:PresentSearchResults(true)
	end
end)

/*
Ends the current playlist/listening session
*/

net.Receive("MEDIA_End", function()
	MEDIA.Playlist = {}
	MEDIA.CurrentVideo = {}

	if (MEDIA.PlaylistPanel and IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:UpdatePlaylist()
		MEDIA.PlaylistPanel:UpdateGrid()
	end

	if (MEDIA.PlayerPanel and IsValid(MEDIA.PlaylistPanel) and MEDIA.PlayerPanel:IsVisible()) then
		local setting = MEDIA.GetSetting("media_player_hide")
		local setting2 = MEDIA.GetSetting("media_all_show") or { Value = 0}

		if (setting.Value == 1 and setting2.Value == 0 ) then
			MEDIA.PlayerPanel:Hide()
		end

		MEDIA.PlayerPanel:SetVideo(MEDIA.CurrentVideo)
	end
end)

/*
Sets the current video
*/

net.Receive("MEDIA_SendCurrentVideo",function()
	MEDIA.CurrentVideo = net.ReadTable()
	MEDIA.CurrentVideo.StartTime = CurTime()

	if (MEDIA.Playlist[MEDIA.CurrentVideo.Video]) then
		MEDIA.Playlist[MEDIA.CurrentVideo.Video].Position = 0
	end

	for k,v in SortedPairsByMemberValue(MEDIA.Playlist, "Position") do
		if (v.Video != MEDIA.CurrentVideo.Video) then MEDIA.Playlist[v.Video].Position = MEDIA.Playlist[v.Video].Position - 1 end
	end

	--update visual elements here
	if (MEDIA.PlaylistPanel and IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:UpdatePlaylist()
	end

	if (MEDIA.PlayerPanel and IsValid(MEDIA.PlaylistPanel)) then
		local setting = MEDIA.GetSetting("media_display_video")

		if (!MEDIA.PlayerPanel:IsVisible() and setting.Value ) then
			MEDIA.PlayerPanel:Show()
		end

		MEDIA.PlayerPanel:SetVideo(MEDIA.CurrentVideo)
	end
end)

/*
Sets the playlist
*/

net.Receive("MEDIA_SendPlaylist",function()

	MEDIA.Playlist = net.ReadTable()

	if (MEDIA.PlaylistPanel and IsValid(MEDIA.PlaylistPanel)) then
		MEDIA.PlaylistPanel:UpdatePlaylist()
	end
end)

/*
Sets admin settings
*/

net.Receive("MEDIA_SendAdminSettings",function()
	MEDIA.AdminSettings = net.ReadTable()
end)

/*
Sets history
*/

net.Receive("MEDIA_SendHistory",function()
	MEDIA.History = net.ReadTable()
end)
