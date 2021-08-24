--[[
The main sorta client side file

see cl_panels for where new panels are defined within the panel controller system
-----------------------------------------------------------------------------
--]]

--player and playlist
MediaPlayer.CurrentVideo = MediaPlayer.CurrentVideo or {}
MediaPlayer.Playlist = MediaPlayer.Playlist or {}

--search stuff
MediaPlayer.History = MediaPlayer.History or {}
MediaPlayer.PlayerHistory = MediaPlayer.PlayerHistory or {}
MediaPlayer.SearchResults = MediaPlayer.SearchResults or {}

--admin stuff
MediaPlayer.Blacklist = MediaPlayer.Blacklist or {}

--For our history page
MediaPlayer.HistoryCount = MediaPlayer.HistoryCount or 1
MediaPlayer.HistoryPageMax = MediaPlayer.HistoryPageMax or 1

--for our player history page
MediaPlayer.PlayerHistoryCount = MediaPlayer.PlayerHistoryCount or 1
MediaPlayer.PlayerPageMax = MediaPlayer.PlayerPageMax or 1

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

hook.Add("PreGamemodeLoaded", "MediaPlayer.PreGamemodeLoaded", function()

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

			RunConsoleCommand("media_admin_panel")
			--instantly remove
			window:Remove()
		end
	})
end)

hook.Add("InitPostEntity", "MediaPlayer.LoadClientAddon", function()
	MediaPlayer.LocalPlayer = LocalPlayer()
	MediaPlayer.InstantiatePanels(true)

	--if the player has ran this addnon before and they have saved settings
	if (MediaPlayer.HasSavedSettings()) then

		--if we don't have preset defaults enabled then we'll just return here
		if (!MediaPlayer.IsSettingTrue("preset_enable_server_default")) then return end

		MediaPlayer.RequestDefaultPreset() --This will check the servers join list and ask for a default preset
		return
	end

	MediaPlayer.WriteDefaultPresets() --this writes default presets from addon folder (if downloaded)
	MediaPlayer.GetDefaultPreset() --this asks the server for the servers default schema
end)

hook.Add("OnContextMenuOpen", "MediaPlayer.ContextMenu", function()
	MediaPlayer.ExecuteContextMenu(true)
end)

hook.Add("OnContextMenuClose", "MediaPlayer.ContextMenu", function()
	MediaPlayer.ExecuteContextMenu(false)
end)

hook.Add("ScoreboardShow", "MediaPlayer.ScoreboardShow", function()
	MediaPlayer.ExecuteScoreboardMenu(true)
end)

hook.Add("ScoreboardHide", "MediaPlayer.ScoreboardHide", function()
	MediaPlayer.ExecuteScoreboardMenu(false)
end)

--[[
Net Functions
-----------------------------------------------------------------------------
--]]


function MediaPlayer.YoutubeSearch(query)

	if (query == nil or query == "") then return end

	net.Start("MediaPlayer.SearchQuery")
	net.WriteString(query)
	net.SendToServer()
end

--[[
Requests and then sets our admin settings if not already sent
--]]

function MediaPlayer.GetAdminSettings()
	if (!MediaPlayer.LocalPlayer:IsAdmin()) then return end

	net.Start("MediaPlayer.RequestAdminSettings")
	--nothing
	net.SendToServer()
end

--[[
Pushes a change to server settings
--]]

function MediaPlayer.SetAdminSettings()
	if (!MediaPlayer.LocalPlayer:IsAdmin()) then return end
	if (table.IsEmpty(MediaPlayer.AdminSettings)) then return end

	net.Start("MediaPlayer.SetAdminSettings")
		net.WriteTable(MediaPlayer.AdminSettings)
	net.SendToServer()
end


--[[
Console Commands
-----------------------------------------------------------------------------
--]]

concommand.Add("media_write_default_presets", function(ply, cmd, args)
	MediaPlayer.WriteDefaultPresets()
end)

concommand.Add("media_refresh_initial_preset", function(ply, cmd, args)
	MediaPlayer.GetDefaultPreset()
end)

--[[
Youtube search function
--]]

concommand.Add("media_youtube_search", function (ply, cmd, args)

	if (args[1] == nil or args[1] == "" ) then return end
	MediaPlayer.YoutubeSearch(args[1])
end)

--[[
Creates all components
--]]

concommand.Add("media_create_cl", function()
	MediaPlayer.InstantiatePanels(true) --
end)


concommand.Add("media_settings_create", function()
	MediaPlayer.ReinstantiatePanel("SettingsPanel")
end)

--[[
Creates all components
--]]

concommand.Add("media_refresh_cl", function()
	MediaPlayer.InstantiatePanels(true, {
		"SettingsPanel" --skips settings panel
	})
end)

--[[
Shows our Search Panel
--]]

concommand.Add("media_search_panel", function()
	MediaPlayer.ShowPanel("SearchPanel")
end)

--[[
Shows our Admin Panel
--]]

concommand.Add("media_admin_panel", function()
	MediaPlayer.ShowPanel("AdminPanel")
end)

--[[
Shows our Settings Panel
--]]

concommand.Add("media_settings", function()
	MediaPlayer.ShowPanel("SettingsPanel")
end)


--[[
Creates Search Panel
--]]

concommand.Add("media_create_search_panel", function()
	MediaPlayer.ReinstantiatePanel("SearchPanel")
end)

--[[
Creates admin panel
--]]


concommand.Add("media_create_admin_panel", function()
	MediaPlayer.ReinstantiatePanel("AdminPanel")
end)

--[[
Creates Vote Panel
--]]

concommand.Add("media_create_vote_panel", function()
	MediaPlayer.ReinstantiatePanel("VotePanel")
end)

--[[
Creates Playlist Panel
--]]

concommand.Add("media_create_player_panel", function()
	MediaPlayer.ReinstantiatePanel("PlayerPanel")
end)

--[[
Creates Playlist Panel
--]]

concommand.Add("media_create_playlist_panel", function()
	MediaPlayer.ReinstantiatePanel("PlaylistPanel")
end)

--[[
Displays the MediaPlayer settings
--]]

concommand.Add("media_create_settings_panel",function()
	MediaPlayer.ReinstantiatePanel("SettingsPanel", true)
end)

--[[
Net stuff
-----------------------------------------------------------------------------
--]]

net.Receive("MediaPlayer.SendMessage", function()
	local msg = net.ReadString() or " null "
	local setting = MediaPlayer.GetSetting("media_chat_colours")

	chat.AddText( setting.Value.PrefixColor, "[" .. MediaPlayer.Name .. "] ", setting.Value.TextColor, msg )
	chat.PlaySound()
end)

--preset stuff

local write = function(preset)
	if (preset.Locked == nil or preset.Locked == false ) then
		preset.Locked = true
	end

	print("writing server.json")

	file.Write("lyds/presets/server.json", util.TableToJSON(preset, true))
end

net.Receive("MediaPlayer.ApplyDefaultPreset", function()

	local preset = net.ReadTable()
	write(preset)

	if (!MediaPlayer.IsSettingTrue("preset_enable_server_default")) then return end

	for k,v in pairs(preset.Settings) do

		if (type(v) == "table") then

			local set = MediaPlayer.GetSetting(k).DefValue
			for key,val in pairs(v) do

				if (set.__unpack != nil and string.sub(key, 1, 2) != "__" ) then
					v[k][key] = set.__unpack(v[key], key, val )
				end

				if (string.sub(key, 1, 2) == "__") then
					v[k][key] = nil
					continue
				end

				--applys the setting
				MediaPlayer.ChangeSetting(k, v[key])
			end
		end

	end
end)

net.Receive("MediaPlayer.RefreshDefaultPreset", function()
	write(net.ReadTable())
end)

--[[
This receives a chunk of history data AKA Paged data
--]]

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

--[[
Recieves personal history data from the server (basically checks for steam id before sending history)
--]]

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

--[[
This receives ALL data
Note: not used atm
--]]

net.Receive("MediaPlayer.SendHistory", function()
	MediaPlayer.History =  net.ReadTable()
	MediaPlayer.HistoryCount = net.ReadFloat()
	MediaPlayer.HistoryPageMax = net.ReadFloat()

	local panel = MediaPlayer.GetPanel("SearchPanel")
	panel:RefreshHistoryGrid()
	panel:AddPageHeader(panel.HistoryGrid, "All History")
	panel:PresentHistory()
end)

--[[
Recieves history data from the server
--]]

net.Receive("MediaPlayer.CreateWarningBox", function()

	if (MediaPlayer.PanelValid("WarningBox")) then
		MediaPlayer.GetPanel("WarningBox"):SetWarning(net.ReadString(), net.ReadString())
		return
	end

	MediaPlayer.CreateWarningBox(net.ReadString(), net.ReadString() )
end)


--[[
Recieves history data from the server
--]]

net.Receive("MediaPlayer.SendHistoryForVideo", function()
	local tab = net.ReadTable()
	MediaPlayer.History[tab.Video] = tab;
end)

--[[
Recieves blacklist data from the server
--]]

net.Receive("MediaPlayer.SendBlacklist", function()
	MediaPlayer.Blacklist = net.ReadTable()

	local panel = MediaPlayer.GetPanel("SearchPanel")
	panel:PresentBlacklist()
end)

--[[
Ends a new vote
--]]

net.Receive("MediaPlayer.EndVote", function()
	MediaPlayer.CurrentVote = {}
	local panel = MediaPlayer.GetPanel("VotePanel")
	panel:Reset()
	panel:Hide()
end)

--[[
Starts a new vote
--]]

net.Receive("MediaPlayer.NewVote", function()
	MediaPlayer.CurrentVote = net.ReadTable()

	local panel = MediaPlayer.GetPanel("VotePanel")
	panel:SetVote(MediaPlayer.CurrentVote)
	panel:Show()
end)

--[[
Sets Search Data
--]]

net.Receive("MediaPlayer.SendSearchResults",function()
	MediaPlayer.SearchResults = net.ReadTable()

	local panel = MediaPlayer.GetPanel("SearchPanel")
	panel:PresentSearchResults(true)
end)

--[[
Ends the current playlist/listening session
--]]

net.Receive("MediaPlayer.End", function()
	MediaPlayer.Playlist = {}
	MediaPlayer.CurrentVideo = {}

	local panel = MediaPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
	panel:UpdateGrid()
	panel:EmptyPanel()

	local setting = MediaPlayer.GetSetting("media_player_hide")
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

--[[
Sets the current video
--]]

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

	if (MediaPlayer.IsSettingTrue("mediaplayer_show_current_video")) then
		panel:Show()
	end
end)

--[[
Sets the playlist
--]]

net.Receive("MediaPlayer.SendPlaylist",function()

	MediaPlayer.Playlist = net.ReadTable()

	local panel = MediaPlayer.GetPanel("PlaylistPanel")
	panel:UpdatePlaylist()
end)

--[[
Sets admin settings
--]]

net.Receive("MediaPlayer.SendAdminSettings",function()
	MediaPlayer.AdminSettings = net.ReadTable()
end)

--[[
Sets history
--]]

net.Receive("MediaPlayer.SendHistory",function()
	MediaPlayer.History = net.ReadTable()
end)
