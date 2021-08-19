--[[
  These are the panels which are used by this addon, they are defined here
]]--

MediaPlayer.Panels = {
	SettingsPanel = {
		Element = "SettingsPanel",
		SettingsBase = "MediaPlayer_settings", --will default to MediaPlayer_default
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel)
			panel:FillPropertySheet({
				Server = MediaPlayer.AdminSettings or {},
				Client = MediaPlayer.Settings or {}
			})
			panel:MakePopup()

			--refreshes
			panel.OnClose = function(self)
				RunConsoleCommand("MediaPlayer_create_cl")
				self:Hide()
			end
		end
	},
	AdminPanel = {
		Element = "AdminPanel",
		SettingsBase = "MediaPlayer_admin",
		Draggable = true,
		Admin = true,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:MakePopup()
		end
	},
	WarningBox = {
		Preloaded = false, --this won't be created and "hidden", instead it'll be created on demand
		Element = "WarningBox",
		SettingsBase = "MediaPlayer_warning",
		Draggable = true,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:Show()
			panel:MakePopup()
		end
	},
	SearchPanel = {
		Element = "SearchPanel",
		SettingsBase = "MediaPlayer_search",
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:MakePopup()
		end
	},
	PlayerPanel = {
		Element = "PlayerPanel",
		SettingsBase = "MediaPlayer_player",
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_Constant = "show_constant"
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()

			if (!table.IsEmpty(MediaPlayer.CurrentVideo)) then
				panel:SetVideo(MediaPlayer.CurrentVideo)

				if (!settings.Hide.Value) then
					panel:Show()
				end
			else
				if (settings.Show_Constant.Value) then
					panel:Show()
				end
			end
		end,
		OnContext = function(panel, key, settings, opened)
			panel:SetKeyboardInputEnabled(opened)
			panel:SetMouseInputEnabled(opened)
		end,
		OnScoreboard =  function(panel, key, settings, opened)
			MediaPlayer.LoadedPanels[key].OnContext(panel,key,settings,opened)
		end
	},
	VotePanel = {
		Element = "VotePanel",
		SettingsBase = "MediaPlayer_vote",
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()
			--nothing needs to be done
			if (table.IsEmpty(MediaPlayer.CurrentVote)) then
				panel:Hide()
			else
				panel:SetVote(MediaPlayer.CurrentVote)
				panel:Show()
			end
		end
	},
	PlaylistPanel = {
		Element = "PlaylistPanel",
		SettingsBase = "MediaPlayer_playlist", --setting base, everything in settings array will build off of this string like so MediaPlayer_playlist_*
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_In_Context = "show_in_context", --this is equiv to MediaPlayer_playlist_show_in_context
			Show_Constant = "show_constant", -- you can append a ! to ignore settings base
			Show_In_Scoreboard = "show_in_scoreboard"
		},
		PostInit = function(panel, key, settings)
			panel:UpdatePlaylist()
			panel:Reposition()
			panel:SetPos(ScrW() - settings.Position.Value.X, settings.Position.Value.Y)

			if (table.IsEmpty(MediaPlayer.Playlist) and !settings.Show_Constant.Value ) then
				panel:Hide()
			elseif (!settings.Hide.Value and settings.Show_Constant.Value) then
				panel:Show()
			end
		end,
		OnContext = function(panel, key, settings, opened)
			if ((!opened or !settings.Show_In_Context.Value or settings.Hide.Value) and !settings.Show_Constant.Value ) then
				panel:Hide()
				return
			end

			if (panel:IsVisible()) then
				panel:MakePopup()
				panel:SetPopupStayAtBack(opened)
				panel:SetKeyboardInputEnabled(opened)
				panel:SetMouseInputEnabled(opened)
			end

			panel:Show()
		end,
		OnScoreboard = function(panel, key, settings, opened)
			if ((!opened or !settings.Show_In_Scoreboard.Value or settings.Hide.Value) and !settings.Show_Constant.Value ) then
				panel:Hide()
				return
			end

			if (panel:IsVisible()) then
				panel:MakePopup()
				panel:SetPopupStayAtBack(opened)
				panel:SetKeyboardInputEnabled(opened)
				panel:SetMouseInputEnabled(opened)
			end

			panel:Show()
		end
	},
}