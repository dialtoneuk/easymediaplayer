--[[
  The main sorta client side file

  see cl_panels for where new panels are defined within the panel controller system
-----------------------------------------------------------------------------
--]]


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

MEDIA.CurrentVote = MEDIA.CurrentVote or {}
MEDIA.AdminSettings = MEDIA.AdminSettings  or {}

--[[
Fonts
-----------------------------------------------------------------------------
--]]

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

surface.CreateFont( "PlaylistText", {
	font = "Arial",
	extended = false,
	size = 22,
	weight = 100,
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

--[[
Hooks
-----------------------------------------------------------------------------
--]]

hook.Add("PreGamemodeLoaded", "MEDIA.PreGamemodeLoaded", function()
	--[[
		This is where the icons for the sandbox context menu are added
	-----------------------------------------------------------------------------
	--]]

	--settings panel
	list.Add( "DesktopWindows", {
		title		= "Media Settings",
		icon		= "icon64/settings.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )
			RunConsoleCommand("media_settings")

			--instantly remove
			window:Remove()
		end
	})

	list.Add( "DesktopWindows", {
		title		= "Media Search",
		icon		= "icon64/search.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )
			RunConsoleCommand("media_search_panel")

			--instantly remove
			window:Remove()
		end
	})

	list.Add( "DesktopWindows", {
		title		= "Like Video",
		icon		= "icon64/like.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )

			if (table.IsEmpty(MEDIA.CurrentVideo)) then
				MEDIA.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
				window:Remove()
				return
			end

			RunConsoleCommand("media_like_video")
			--instantly remove
			window:Remove()
		end
	})

	list.Add( "DesktopWindows", {
		title		= "Dislike Video",
		icon		= "icon64/dislike.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )

			if (table.IsEmpty(MEDIA.CurrentVideo)) then
				MEDIA.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
				window:Remove()
				return
			end

			RunConsoleCommand("media_dislike_video")
			--instantly remove
			window:Remove()
		end
	})

	list.Add( "DesktopWindows", {
		title		= "Media Admin",
		icon		= "icon64/admin.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )

			if ( !LocalPlayer():IsAdmin()) then

				MEDIA.CreateWarningBox("Permissions Denied!","You'll need to be an admin of the server to view the admin dashboard")
				window:Remove()
				return
			end

			RunConsoleCommand("media_admin_panel")
			--instantly remove
			window:Remove()
		end
	})
end)

hook.Add("InitPostEntity", "MEDIA.LoadClientAddon", function()
	MEDIA.LocalPlayer = LocalPlayer()
	MEDIA.InstantiatePanels(true)
end)

hook.Add("OnContextMenuOpen", "MEDIA.ContextMenu", function()
	MEDIA.ExecuteContextMenu(true)
end)

hook.Add("OnContextMenuClose", "MEDIA.ContextMenu", function()
	MEDIA.ExecuteContextMenu(false)
end)

hook.Add("ScoreboardShow", "MEDIA.ScoreboardShow", function()
	MEDIA.ExecuteScoreboardMenu(true)
end)

hook.Add("ScoreboardHide", "MEDIA.ScoreboardHide", function()
	MEDIA.ExecuteScoreboardMenu(false)
end)

--[[
 Net Functions
-----------------------------------------------------------------------------
--]]


function MEDIA.YoutubeSearch(query)

	if (query == nil or query == "") then return end

	net.Start("MEDIA.SearchQuery")
		net.WriteString(query)
	net.SendToServer()
end

--[[
Requests and then sets our admin settings if not already sent
--]]

function MEDIA.GetAdminSettings()
	if (!MEDIA.LocalPlayer:IsAdmin()) then return end

	net.Start("MEDIA.RequestAdminSettings")
	--nothing
	net.SendToServer()
end

--[[
Pushes a change to server settings
--]]

function MEDIA.SetAdminSettings()
	if (!MEDIA.LocalPlayer:IsAdmin()) then return end
	if (table.IsEmpty(MEDIA.AdminSettings)) then return end

	net.Start("MEDIA.SetAdminSettings")
		net.WriteTable(MEDIA.AdminSettings)
	net.SendToServer()
end


--[[
Console Commands
-----------------------------------------------------------------------------
--]]

--[[
Youtube search function
--]]

concommand.Add("media_youtube_search", function (ply, cmd, args)

	if (args[1] == nil or args[1] == "" ) then return end
	MEDIA.YoutubeSearch(args[1])
end)

--[[
Creates all components
--]]

concommand.Add("media_create_cl", function()
	MEDIA.InstantiatePanels(true) --
end)

--[[
Creates all components
--]]

concommand.Add("media_refresh_cl", function()
	MEDIA.InstantiatePanels(true, {
		"SettingsPanel" --skips settings panel
	})
end)

--[[
Shows our Search Panel
--]]

concommand.Add("media_search_panel", function()
	MEDIA.ShowPanel("SearchPanel")
end)

--[[
Shows our Admin Panel
--]]

concommand.Add("media_admin_panel", function()
	MEDIA.ShowPanel("AdminPanel")
end)

--[[
Shows our Settings Panel
--]]

concommand.Add("media_settings", function()
	MEDIA.ShowPanel("SettingsPanel")
end)


--[[
Creates Search Panel
--]]

concommand.Add("media_create_search_panel", function()
	MEDIA.ReinstantiatePanel("SearchPanel")
end)

--[[
	Creates admin panel
--]]


concommand.Add("media_create_admin_panel", function()
	MEDIA.ReinstantiatePanel("AdminPanel")
end)

--[[
Creates Vote Panel
--]]

concommand.Add("media_create_vote_panel", function()
	MEDIA.ReinstantiatePanel("VotePanel")
end)

--[[
Creates Playlist Panel
--]]

concommand.Add("media_create_player_panel", function()
	MEDIA.ReinstantiatePanel("PlayerPanel")
end)

--[[
Creates Playlist Panel
--]]

concommand.Add("media_create_playlist_panel", function()
	MEDIA.ReinstantiatePanel("PlaylistPanel")
end)

--[[
Displays the media settings
--]]

concommand.Add("media_create_settings_panel",function()
	MEDIA.ReinstantiatePanel("SettingsPanel", true)
end)

--[[
Net stuff
-----------------------------------------------------------------------------
--]]

net.Receive("MEDIA.SendMessage", function()
	local msg = net.ReadString() or " null "
	local setting = MEDIA.GetSetting("media_chat_colours")

	chat.AddText( setting.Value.PrefixColor, "[" .. MEDIA.Name .. "] ", setting.Value.TextColor, msg )
	chat.PlaySound()
end)

--[[
	This receives a chunk of history data AKA Paged data
--]]

net.Receive("MEDIA.SendHistoryData", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MEDIA.History = tab
	MEDIA.HistoryCount = net.ReadFloat()
	MEDIA.HistoryPageMax = net.ReadFloat()


	local panel = MEDIA.GetPanel("SearchPanel")

	--now, add it to the search panel
	panel:AddPageHeader(panel.HistoryGrid, panel.HistoryPage)
	panel:PresentHistory()
	panel.HistoryPage = panel.HistoryPage + 1
end)

--[[
Recieves personal history data from the server (basically checks for steam id before sending history)
--]]

net.Receive("MEDIA.SendPersonalHistory", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MEDIA.PlayerHistory = tab
	MEDIA.PlayerHistoryCount = net.ReadFloat()
	MEDIA.PlayerHistoryPageMax = net.ReadFloat()

	local panel = MEDIA.GetPanel("SearchPanel")

	panel:AddPageHeader(panel.PlayerHistoryGrid, panel.PlayerHistoryPage, MEDIA.PlayerHistoryCount)
	panel:PresentPlayerHistory()
	panel.PlayerHistoryPage = panel.PlayerHistoryPage + 1
end)

--[[
 This receives ALL data
  Note: not used atm
--]]

net.Receive("MEDIA.SendHistory", function()
	MEDIA.History =  net.ReadTable()
	MEDIA.HistoryCount = net.ReadFloat()
	MEDIA.HistoryPageMax = net.ReadFloat()

	local panel = MEDIA.GetPanel("SearchPanel")
	panel:RefreshHistoryGrid()
	panel:AddPageHeader(panel.HistoryGrid, "All History")
	panel:PresentHistory()
end)

--[[
Recieves history data from the server
--]]

net.Receive("MEDIA.CreateWarningBox", function()
	MEDIA.CreateWarningBox(net.ReadString(), net.ReadString() )
end)


--[[
Recieves history data from the server
--]]

net.Receive("MEDIA.SendHistoryForVideo", function()
	local tab = net.ReadTable()
	MEDIA.History[tab.Video] = tab;
end)

--[[
Recieves blacklist data from the server
--]]

net.Receive("MEDIA.SendBlacklist", function()
	MEDIA.Blacklist = net.ReadTable()

	local panel = MEDIA.GetPanel("SearchPanel")
	panel:PresentBlacklist()
end)

--[[
Ends a new vote
--]]

net.Receive("MEDIA.EndVote", function()
	MEDIA.CurrentVote = {}
	local panel = MEDIA.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)

--[[
Starts a new vote
--]]

net.Receive("MEDIA.NewVote", function()
	MEDIA.CurrentVote = net.ReadTable()

	local panel = MEDIA.GetPanel("VotePanel")
	panel:SetVote(MEDIA.CurrentVote)
	panel:Show()
end)

--[[
Sets Search Data
--]]

net.Receive("MEDIA.SendSearchResults",function()
	MEDIA.SearchResults = net.ReadTable()

	local panel = MEDIA.GetPanel("SearchPanel")
	panel:PresentSearchResults(true)
end)

--[[
Ends the current playlist/listening session
--]]

net.Receive("MEDIA.End", function()
	MEDIA.Playlist = {}
	MEDIA.CurrentVideo = {}

	local panel = MEDIA.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()
	panel:EmptyPanel()

	local setting = MEDIA.GetSetting("media_player_hide")
	panel = MEDIA.GetPanel("PlayerPanel")
	panel:SetVideo(MEDIA.CurrentVideo)

	if (setting.Value) then
		panel:Hide()
	end

	MEDIA.CurrentVote = {}
	panel = MEDIA.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)

--[[
Sets the current video
--]]

net.Receive("MEDIA.SendCurrentVideo",function()
	MEDIA.CurrentVideo = net.ReadTable()
	MEDIA.CurrentVideo.StartTime = CurTime()

	if (MEDIA.Playlist[MEDIA.CurrentVideo.Video]) then
		MEDIA.Playlist[MEDIA.CurrentVideo.Video].Position = 0
	end

	for k,v in SortedPairsByMemberValue(MEDIA.Playlist, "Position") do
		if (v.Video != MEDIA.CurrentVideo.Video) then MEDIA.Playlist[v.Video].Position = MEDIA.Playlist[v.Video].Position - 1 end
	end

	--update visual elements here
	local panel = MEDIA.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()

	panel = MEDIA.GetPanel("PlayerPanel")
	panel:SetVideo(MEDIA.CurrentVideo)
	panel:Show()
end)

--[[
Sets the playlist
--]]

net.Receive("MEDIA.SendPlaylist",function()

	MEDIA.Playlist = net.ReadTable()

	local panel = MEDIA.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
end)

--[[
Sets admin settings
--]]

net.Receive("MEDIA.SendAdminSettings",function()
	MEDIA.AdminSettings = net.ReadTable()
end)

--[[
Sets history
--]]

net.Receive("MEDIA.SendHistory",function()
	MEDIA.History = net.ReadTable()
end)
