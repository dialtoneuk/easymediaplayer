
--playlist and current video
LydsPlayer.CurrentVideo = LydsPlayer.CurrentVideo or {}
LydsPlayer.Playlist = LydsPlayer.Playlist or {}

--History and Playhistory client tables
LydsPlayer.Session = LydsPlayer.Session or {} --contains servers history (is not 1 to 1 w/ server)
LydsPlayer.PlayerSession = LydsPlayer.PlayerSession or {} --contains players history (is not 1 to 1)

--Page max (for page math)
LydsPlayer.HistoryMax = LydsPlayer.HistoryMax or 30

--admin stuff
LydsPlayer.Blacklist = LydsPlayer.Blacklist or {} --only filled if admin

--For our history page

LydsPlayer.CurrentVote = LydsPlayer.CurrentVote or {}
LydsPlayer.AdminSettings = LydsPlayer.AdminSettings  or {}

--[[
	Fonts
	-----------------------------------------------------------------------------
--]]

surface.CreateFont( "BiggerText", {
	font = "Arial",
	extended = false,
	size = 25,
	weight = 200,
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


surface.CreateFont( "PlaylistBigText", {
	font = "Arial",
	extended = false,
	size = 22,
	weight = 200,
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

surface.CreateFont( "PlaylistText", {
	font = "Arial",
	extended = false,
	size = 19,
	weight = 200,
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

surface.CreateFont( "BigText", {
	font = "Arial",
	extended = false,
	size = 16,
	weight = 200,
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

surface.CreateFont( "MediumText", {
	font = "Arial",
	extended = false,
	size = 14,
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
	size = 14,
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
hook.Add("PreGamemodeLoaded", "LydsPlayer.PreGamemodeLoaded", function()

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

			if (table.IsEmpty(LydsPlayer.CurrentVideo)) then
				LydsPlayer.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
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

			if (table.IsEmpty(LydsPlayer.CurrentVideo)) then
				LydsPlayer.CreateWarningBox("No Current Video!","There isn't even a video playing! Try playing one first.")
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

			if ( !LydsPlayer.LocalPlayer:IsAdmin()) then
				LydsPlayer.CreateWarningBox("Permissions Denied!","You'll need to be an admin of the server to view the admin dashboard", 4)
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
hook.Add("InitPostEntity", "LydsPlayer.LoadClientAddon", function()
	LydsPlayer.LocalPlayer = LocalPlayer()
	LydsPlayer.InstantiatePanels(true)

	--if the player has ran this addnon before and they have saved settings
	if (LydsPlayer.HasSavedSettings()) then

		--if we don't have preset defaults enabled then we'll just return here
		if (!LydsPlayer.IsSettingTrue("preset_allow_initial")) then return end

		LydsPlayer.RequestDefaultPreset() --This will check the servers join list and ask for a default preset
		return
	else
		--this is their first time
		LydsPlayer.WriteDefaultPresets()

		--now lets try and load our default preset
		LydsPlayer.ApplyDefaultPreset()
	end

	--will reinstantiate panels
	LydsPlayer.GetDefaultPreset() --this asks the server for the servers default schema
end)

--hook onto context menu open, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("OnContextMenuOpen", "LydsPlayer.ContextMenu", function()
	LydsPlayer.ExecuteContextMenu(true)
end)

--hook onto context menu hide, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("OnContextMenuClose", "LydsPlayer.ContextMenu", function()
	LydsPlayer.ExecuteContextMenu(false)
end)

--hook onto scoreboard menu, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("ScoreboardShow", "LydsPlayer.ScoreboardShow", function()
	LydsPlayer.ExecuteScoreboardMenu(true)
end)

--hook onto scoreboard menu, see cl_panels_controller.lua, arg 1 is simply visibility
hook.Add("ScoreboardHide", "LydsPlayer.ScoreboardHide", function()
	LydsPlayer.ExecuteScoreboardMenu(false)
end)


--[[
	Console Commands
	-----------------------------------------------------------------------------
--]]

--writeDefaultPreset our default presets to file contained inside autorun/presets.lua
concommand.Add("media_write_default_presets", function(ply, cmd, args)
	LydsPlayer.WriteDefaultPresets()
end)

--gets the initial preset from the server and applies it
concommand.Add("media_refresh_initial_preset", function(ply, cmd, args)
	LydsPlayer.GetDefaultPreset()
end)

--searches youtube
concommand.Add("media_search", function (ply, cmd, args)

	local typ = args[1]
	local query = args[2]

	if (typ == LydsPlayer.MediaType.YOUTUBE or typ == LydsPlayer.MediaType.YoutubeMusic) then
		LydsPlayer.YoutubeSearch(query)
	else
		--others
		print("not implemented")
	end
end)

--recreates all UI components
concommand.Add("media_create_cl", function()
	LydsPlayer.InstantiatePanels(true) --
end)

--recreates settings panel
concommand.Add("settings_create", function()
	LydsPlayer.ReinstantiatePanel("SettingsPanel")
end)

--recreates all panels except the settings panel
concommand.Add("media_refresh_cl", function()
	LydsPlayer.InstantiatePanels(true, {
		"SettingsPanel" --skips settings panel
	})
end)

--show search panel
concommand.Add("search_panel", function()
	LydsPlayer.ShowPanel("SearchPanel")
end)

--mutes or unmutes a video
concommand.Add("media_mute_video", function()
	if (LydsPlayer.GetSetting("player_mute").Value) then
		LydsPlayer.ChangeSetting("player_mute", false );
		LydsPlayer.CreateChatMessage("Unmuted!")
	else
		LydsPlayer.ChangeSetting("player_mute", true );
		LydsPlayer.CreateChatMessage("Muted")
	end

	LydsPlayer.ReinstantiatePanel("PlayerPanel")
end)

--show admin panel
concommand.Add("admin_panel", function()
	LydsPlayer.ShowPanel("AdminPanel")
end)

--show settings panel
concommand.Add("settings", function()
	LydsPlayer.ShowPanel("SettingsPanel")
end)

--various creation commands for panels
--search
concommand.Add("media_create_search_panel", function()
	LydsPlayer.ReinstantiatePanel("SearchPanel")
end)

--admin
concommand.Add("media_create_admin_panel", function()
	LydsPlayer.ReinstantiatePanel("AdminPanel")
end)

--vote
concommand.Add("media_create_vote_panel", function()
	LydsPlayer.ReinstantiatePanel("VotePanel")
end)

--player
concommand.Add("media_create_player_panel", function()
	LydsPlayer.ReinstantiatePanel("PlayerPanel")
end)

--playlist
concommand.Add("media_create_playlist_panel", function()
	LydsPlayer.ReinstantiatePanel("PlaylistPanel")
end)

--settings
concommand.Add("media_create_settings_panel",function()
	LydsPlayer.ReinstantiatePanel("SettingsPanel", true)
end)

--[[
	Clients Net Receieves
	-----------------------------------------------------------------------------
--]]


--writes the servers local preset to file
--TODO: Maybe move this into a func inside LydsPlayer.?
local writeDefaultPreset = function(preset)
	if (preset.Locked == nil or preset.Locked == false ) then
		preset.Locked = true
	end

	print("writing server.json")

	file.Write("lyds/presets/server.json", util.TableToJSON(preset, true))
end

net.Receive("LydsPlayer.SendHistory", function()

	local results = net.ReadTable()
	local historymax = net.ReadTable()

	LydsPlayer.HistoryMax = historymax

	if (LydsPlayer.PanelValid("SearchPanel")) then
		LydsPlayer.GetPanel("SearchPanel").SearchHistoryContainer:SetSearchResults(results)
	end
end)

net.Receive("LydsPlayer.ApplyDefaultPreset", function()

	local preset = net.ReadTable()
	writeDefaultPreset(preset)

	if (!LydsPlayer.IsSettingTrue("preset_allow_initial")) then return end

	LydsPlayer.ApplyPreset(preset)
	LydsPlayer.InstantiatePanels(true)
end)

net.Receive("LydsPlayer.RefreshDefaultPreset", function()
	writeDefaultPreset(net.ReadTable())
end)

--receives a message from the server and puts it into the players chat
net.Receive("LydsPlayer.SendMediaPlayerMessage", function()

	local str = net.ReadString()
	local bool = net.ReadBool()
	bool = !bool

	LydsPlayer.CreateChatMessage(str, bool)
end)


--receives a chunk of history data from the server, not the full thing
net.Receive("LydsPlayer.SendSessionChunk", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	LydsPlayer.Session = tab

	if (LydsPlayer.PanelValid("SearchPanel")) then
		LydsPlayer.PanelValid("SearchPanel").Panel.SearchSessionContainer:SetSearchResults(LydsPlayer.Session)
	end
end)

--receives a chunk of personal history data from the server, not the full thing. (personal history data is simply videos the user has submitted)
net.Receive("LydsPlayer.SendPersonalSession", function()
	local tab = net.ReadTable();

	if (table.IsEmpty(tab)) then
		return
	end

	LydsPlayer.PlayerSession = tab

	if (LydsPlayer.PanelValid("SearchPanel")) then
		LydsPlayer.PanelValid("SearchPanel").Panel.SearchSessionContainer:SetSearchResults(LydsPlayer.PlayerSession)
	end
end)

--receives all the history from the server
net.Receive("LydsPlayer.SendSession", function()
	LydsPlayer.Session = net.ReadTable()

	if (LydsPlayer.PanelValid("SearchPanel")) then
		LydsPlayer.PanelValid("SearchPanel").Panel.SearchSessionContainer:SetSearchResults(LydsPlayer.Session)
	end
end)


--Creates a warning box, sent from server
net.Receive("LydsPlayer.CreateWarningBox", function()

	if (LydsPlayer.PanelValid("WarningBox")) then
		LydsPlayer.GetPanel("WarningBox"):SetWarning(net.ReadString(), net.ReadString())
		return
	end

	LydsPlayer.CreateWarningBox(net.ReadString(), net.ReadString() )
end)


--Receives history for a singular video
net.Receive("LydsPlayer.SendSessionForVideo", function()
	local tab = net.ReadTable()
	LydsPlayer.Session[tab.Video] = tab;
end)

--The blacklist full of banned videos
net.Receive("LydsPlayer.SendBlacklist", function()
	LydsPlayer.Blacklist = net.ReadTable()

	if (LydsPlayer.PanelValid("AdminPanel")) then
		local panel = LydsPlayer.GetPanel("AdminPanel")
		panel:PresentBlacklist()
	end
end)

--Our enabled media types
net.Receive("LydsPlayer.EnabledMediaTypes", function()
	LydsPlayer.EnabledMediaTypes = net.ReadTable()

	if (LydsPlayer.PanelValid("SearchPanel")) then
		local panel = LydsPlayer.GetPanel("SearchPanel")
		panel:RebuildComboBox()
	end
end)

--Received when a vote has ended
net.Receive("LydsPlayer.EndVote", function()
	LydsPlayer.CurrentVote = {}
	local panel = LydsPlayer.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)


--Received when a vote has begun
net.Receive("LydsPlayer.NewVote", function()
	LydsPlayer.CurrentVote = net.ReadTable()

	local panel = LydsPlayer.GetPanel("VotePanel")
	panel:SetVote(LydsPlayer.CurrentVote)
	panel:Show()
end)


--Received when search results have been returned
net.Receive("LydsPlayer.SendSearchResults",function()
	local tab = net.ReadTable()
	local typ = net.ReadString()
	local panel = LydsPlayer.GetPanel("SearchPanel")

	panel:ShowResults(typ, tab)
end)

--Received when the playlist has ended
net.Receive("LydsPlayer.End", function()
	LydsPlayer.Playlist = {}
	LydsPlayer.CurrentVideo = {}

	local panel = LydsPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()
	panel:EmptyPanel()

	local setting = LydsPlayer.GetSetting("player_hide")
	panel = LydsPlayer.GetPanel("PlayerPanel")
	panel:SetVideo(LydsPlayer.CurrentVideo)

	if (setting.Value) then
		panel:Hide()
	end

	LydsPlayer.CurrentVote = {}
	panel = LydsPlayer.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)

--Received when a new video is playing, sets the current video in the playlist and removes that video from the playlist position, updating all other positions to down one.
net.Receive("LydsPlayer.SendCurrentVideo",function()
	LydsPlayer.CurrentVideo = net.ReadTable()
	LydsPlayer.CurrentVideo.StartTime = CurTime()

	if (LydsPlayer.Playlist[LydsPlayer.CurrentVideo.Video]) then
		LydsPlayer.Playlist[LydsPlayer.CurrentVideo.Video].Position = 0
	end

	for k,v in SortedPairsByMemberValue(LydsPlayer.Playlist, "Position") do
		if (v.Video != LydsPlayer.CurrentVideo.Video) then LydsPlayer.Playlist[v.Video].Position = LydsPlayer.Playlist[v.Video].Position - 1 end
	end

	--update visual elements here
	local panel = LydsPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()

	panel = LydsPlayer.GetPanel("PlayerPanel")
	panel:SetVideo(LydsPlayer.CurrentVideo)

	if (LydsPlayer.IsSettingTrue("player_show_current_video")) then
		panel:Show()
	end
end)

--receives the playlist from the server
net.Receive("LydsPlayer.SendPlaylist",function()

	LydsPlayer.Playlist = net.ReadTable()

	local panel = LydsPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
end)

--receives admin settings from the server
net.Receive("LydsPlayer.SendMediaPlayerAdminSettings",function()
	LydsPlayer.AdminSettings = net.ReadTable()
end)