
--playlist and current video
MediaPlayer.CurrentVideo = MediaPlayer.CurrentVideo or {}
MediaPlayer.Playlist = MediaPlayer.Playlist or {}

--History and Playhistory client tables
MediaPlayer.History = MediaPlayer.History or {} --contains servers history (is not 1 to 1 w/ server)
MediaPlayer.PlayerHistory = MediaPlayer.PlayerHistory or {} --contains players history (is not 1 to 1)
MediaPlayer.SearchResults = MediaPlayer.SearchResults or {}

--admin stuff
MediaPlayer.Blacklist = MediaPlayer.Blacklist or {} --only filled if admin

--For our history page
MediaPlayer.HistoryCount = MediaPlayer.HistoryCount or 1 --how many history elements in total

--TODO: Move this to be completely a client side variable
MediaPlayer.HistoryPageMax = MediaPlayer.HistoryPageMax or 1 --how many elements at max can appear

--for our player history page
MediaPlayer.PlayerHistoryCount = MediaPlayer.PlayerHistoryCount or 1 --how many history elements in total

--TODO: Move this to be completely a client side variable
MediaPlayer.PlayerPageMax = MediaPlayer.PlayerPageMax or 1 --how many elements at max can appear

MediaPlayer.CurrentVote = MediaPlayer.CurrentVote or {}
MediaPlayer.AdminSettings = MediaPlayer.AdminSettings  or {}

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

surface.CreateFont( "BigText", {
	font = "Arial",
	extended = false,
	size = 18,
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
	size = 16,
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
	size = 12,
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

--adds icons to sandbox context menu
hook.Add("PreGamemodeLoaded", "MediaPlayer.PreGamemodeLoaded", function()

	--settings panel
	list.Add( "DesktopWindows", {
		title		= "Media Settings",
		icon		= "icon64/settings.png",
		width		= 10,
		height		= 10,
		onewindow	= true,
		init		= function( icon, window )
			RunConsoleCommand("settings")

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
			RunConsoleCommand("search_panel")

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

			if (table.IsEmpty(MediaPlayer.CurrentVideo)) then
				MediaPlayer.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
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

			if (table.IsEmpty(MediaPlayer.CurrentVideo)) then
				MediaPlayer.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
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

			if ( !MediaPlayer.LocalPlayer:IsAdmin()) then
				MediaPlayer.CreateWarningBox("Permissions Denied!","You'll need to be an admin of the server to view the admin dashboard", 4)
				window:Remove()
				return
			end

			RunConsoleCommand("admin_panel")
			--instantly remove
			window:Remove()
		end
	})
end)

--ran after all entities have been initiated, here we instantiate panels and apply a default preset if its our first time joining/running
hook.Add("InitPostEntity", "MediaPlayer.LoadClientAddon", function()
	MediaPlayer.LocalPlayer = LocalPlayer()
	MediaPlayer.InstantiatePanels(true)

	--if the player has ran this addnon before and they have saved settings
	if (MediaPlayer.HasSavedSettings()) then

		--if we don't have preset defaults enabled then we'll just return here
		if (!MediaPlayer.IsSettingTrue("preset_allow_initial")) then return end

		MediaPlayer.RequestDefaultPreset() --This will check the servers join list and ask for a default preset
		return
	else
		--this is their first time
		MediaPlayer.WriteDefaultPresets()

		--now lets try and load our default preset
		MediaPlayer.ApplyDefaultPreset()
	end

	--will reinstantiate panels
	MediaPlayer.GetDefaultPreset() --this asks the server for the servers default schema
end)

--hook onto context menu open, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("OnContextMenuOpen", "MediaPlayer.ContextMenu", function()
	MediaPlayer.ExecuteContextMenu(true)
end)

--hook onto context menu hide, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("OnContextMenuClose", "MediaPlayer.ContextMenu", function()
	MediaPlayer.ExecuteContextMenu(false)
end)

--hook onto scoreboard menu, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("ScoreboardShow", "MediaPlayer.ScoreboardShow", function()
	MediaPlayer.ExecuteScoreboardMenu(true)
end)

--hook onto scoreboard menu, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("ScoreboardHide", "MediaPlayer.ScoreboardHide", function()
	MediaPlayer.ExecuteScoreboardMenu(false)
end)


--[[
	Console Commands
	-----------------------------------------------------------------------------
--]]

--writeDefaultPreset our default presets to file contained inside autorun/presets.lua
concommand.Add("media_write_default_presets", function(ply, cmd, args)
	MediaPlayer.WriteDefaultPresets()
end)

--gets the initial preset from the server and applies it
concommand.Add("media_refresh_initial_preset", function(ply, cmd, args)
	MediaPlayer.GetDefaultPreset()
end)

--searches youtube
concommand.Add("media_youtube_search", function (ply, cmd, args)

	if (args[1] == nil or args[1] == "" ) then return end
	MediaPlayer.YoutubeSearch(args[1])
end)

--recreates all UI components
concommand.Add("media_create_cl", function()
	MediaPlayer.InstantiatePanels(true) --
end)

--recreates settings panel
concommand.Add("settings_create", function()
	MediaPlayer.ReinstantiatePanel("SettingsPanel")
end)

--recreates all panels except the settings panel
concommand.Add("media_refresh_cl", function()
	MediaPlayer.InstantiatePanels(true, {
		"SettingsPanel" --skips settings panel
	})
end)

--show search panel
concommand.Add("search_panel", function()
	MediaPlayer.ShowPanel("SearchPanel")
end)

--mutes or unmutes a video
concommand.Add("media_mute_video", function()
	if (MediaPlayer.GetSetting("player_mute").Value) then
		MediaPlayer.ChangeSetting("player_mute", false );
		MediaPlayer.CreateChatMessage("Unmuted!")
	else
		MediaPlayer.ChangeSetting("player_mute", true );
		MediaPlayer.CreateChatMessage("Muted")
	end

	MediaPlayer.ReinstantiatePanel("PlayerPanel")
end)

--show admin panel
concommand.Add("admin_panel", function()
	MediaPlayer.ShowPanel("AdminPanel")
end)

--show settings panel
concommand.Add("settings", function()
	MediaPlayer.ShowPanel("SettingsPanel")
end)

--various creation commands for panels
--search
concommand.Add("media_create_search_panel", function()
	MediaPlayer.ReinstantiatePanel("SearchPanel")
end)

--admin
concommand.Add("media_create_admin_panel", function()
	MediaPlayer.ReinstantiatePanel("AdminPanel")
end)

--vote
concommand.Add("media_create_vote_panel", function()
	MediaPlayer.ReinstantiatePanel("VotePanel")
end)

--player
concommand.Add("media_create_player_panel", function()
	MediaPlayer.ReinstantiatePanel("PlayerPanel")
end)

--playlist
concommand.Add("media_create_playlist_panel", function()
	MediaPlayer.ReinstantiatePanel("PlaylistPanel")
end)

--settings
concommand.Add("media_create_settings_panel",function()
	MediaPlayer.ReinstantiatePanel("SettingsPanel", true)
end)

--[[
	Clients Net Receieves
	-----------------------------------------------------------------------------
--]]


--writes the servers local preset to file
--TODO: Maybe move this into a func inside MediaPlayer.?
local writeDefaultPreset = function(preset)
	if (preset.Locked == nil or preset.Locked == false ) then
		preset.Locked = true
	end

	print("writing server.json")

	file.Write("lyds/presets/server.json", util.TableToJSON(preset, true))
end

net.Receive("MediaPlayer.ApplyDefaultPreset", function()

	local preset = net.ReadTable()
	writeDefaultPreset(preset)

	if (!MediaPlayer.IsSettingTrue("preset_allow_initial")) then return end

	MediaPlayer.ApplyPreset(preset)
	MediaPlayer.InstantiatePanels(true)
end)

net.Receive("MediaPlayer.RefreshDefaultPreset", function()
	writeDefaultPreset(net.ReadTable())
end)

--receives a message from the server and puts it into the players chat
net.Receive("MediaPlayer.SendMessage", function()
	MediaPlayer.CreateChatMessage(net.ReadString())
end)


--receives a chunk of history data from the server, not the full thing
net.Receive("MediaPlayer.SendHistoryData", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MediaPlayer.History = tab
	MediaPlayer.HistoryCount = net.ReadFloat()
	MediaPlayer.HistoryPageMax = net.ReadFloat()


	local panel = MediaPlayer.GetPanel("SearchPanel")

	--now, add it to the search panel
	panel:AddPageHeader(panel.HistoryGrid, panel.HistoryPage)
	panel:PresentHistory()
	panel.HistoryPage = panel.HistoryPage + 1
end)

--receives a chunk of personal history data from the server, not the full thing. (personal history data is simply videos the user has submitted)
net.Receive("MediaPlayer.SendPersonalHistory", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	MediaPlayer.PlayerHistory = tab
	MediaPlayer.PlayerHistoryCount = net.ReadFloat()
	MediaPlayer.PlayerHistoryPageMax = net.ReadFloat()

	local panel = MediaPlayer.GetPanel("SearchPanel")

	panel:AddPageHeader(panel.PlayerHistoryGrid, panel.PlayerHistoryPage, MediaPlayer.PlayerHistoryCount)
	panel:PresentPlayerHistory()
	panel.PlayerHistoryPage = panel.PlayerHistoryPage + 1
end)

--receives all the history from the server
net.Receive("MediaPlayer.SendHistory", function()
	MediaPlayer.History =  net.ReadTable()
	MediaPlayer.HistoryCount = net.ReadFloat()
	MediaPlayer.HistoryPageMax = net.ReadFloat()

	local panel = MediaPlayer.GetPanel("SearchPanel")
	panel:RefreshHistoryGrid()
	panel:AddPageHeader(panel.HistoryGrid, "All History")
	panel:PresentHistory()
end)


--Creates a warning box, sent from server
net.Receive("MediaPlayer.CreateWarningBox", function()

	if (MediaPlayer.PanelValid("WarningBox")) then
		MediaPlayer.GetPanel("WarningBox"):SetWarning(net.ReadString(), net.ReadString())
		return
	end

	MediaPlayer.CreateWarningBox(net.ReadString(), net.ReadString() )
end)


--Receives history for a singular video
net.Receive("MediaPlayer.SendHistoryForVideo", function()
	local tab = net.ReadTable()
	MediaPlayer.History[tab.Video] = tab;
end)

--The blacklist full of banned videos
net.Receive("MediaPlayer.SendBlacklist", function()
	MediaPlayer.Blacklist = net.ReadTable()

	if (MediaPlayer.PanelValid("AdminPanel")) then
		local panel = MediaPlayer.GetPanel("AdminPanel")
		panel:PresentBlacklist()
	end
end)

--Received when a vote has ended
net.Receive("MediaPlayer.EndVote", function()
	MediaPlayer.CurrentVote = {}
	local panel = MediaPlayer.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)


--Received when a vote has begun
net.Receive("MediaPlayer.NewVote", function()
	MediaPlayer.CurrentVote = net.ReadTable()

	local panel = MediaPlayer.GetPanel("VotePanel")
	panel:SetVote(MediaPlayer.CurrentVote)
	panel:Show()
end)


--Received when search results have been returned
net.Receive("MediaPlayer.SendSearchResults",function()
	MediaPlayer.SearchResults = net.ReadTable()

	local panel = MediaPlayer.GetPanel("SearchPanel")
	panel:PresentSearchResults(true)
end)

--Received when the playlist has ended
net.Receive("MediaPlayer.End", function()
	MediaPlayer.Playlist = {}
	MediaPlayer.CurrentVideo = {}

	local panel = MediaPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()
	panel:EmptyPanel()

	local setting = MediaPlayer.GetSetting("player_hide")
	panel = MediaPlayer.GetPanel("PlayerPanel")
	panel:SetVideo(MediaPlayer.CurrentVideo)

	if (setting.Value) then
		panel:Hide()
	end

	MediaPlayer.CurrentVote = {}
	panel = MediaPlayer.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)

--Received when a new video is playing, sets the current video in the playlist and removes that video from the playlist position, updating all other positions to down one.
net.Receive("MediaPlayer.SendCurrentVideo",function()
	MediaPlayer.CurrentVideo = net.ReadTable()
	MediaPlayer.CurrentVideo.StartTime = CurTime()

	if (MediaPlayer.Playlist[MediaPlayer.CurrentVideo.Video]) then
		MediaPlayer.Playlist[MediaPlayer.CurrentVideo.Video].Position = 0
	end

	for k,v in SortedPairsByMemberValue(MediaPlayer.Playlist, "Position") do
		if (v.Video != MediaPlayer.CurrentVideo.Video) then MediaPlayer.Playlist[v.Video].Position = MediaPlayer.Playlist[v.Video].Position - 1 end
	end

	--update visual elements here
	local panel = MediaPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()

	panel = MediaPlayer.GetPanel("PlayerPanel")
	panel:SetVideo(MediaPlayer.CurrentVideo)

	if (MediaPlayer.IsSettingTrue("player_show_current_video")) then
		panel:Show()
	end
end)

--receives the playlist from the server
net.Receive("MediaPlayer.SendPlaylist",function()

	MediaPlayer.Playlist = net.ReadTable()

	local panel = MediaPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
end)

--receives admin settings from the server
net.Receive("MediaPlayer.SendAdminSettings",function()
	MediaPlayer.AdminSettings = net.ReadTable()
end)