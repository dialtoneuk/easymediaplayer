
--These are all the panels used by the addon.
--see cl_panels_controller.lua for how the data here is then instantiated and ready for us to use
LydsPlayer.Panels = {

	--settings panel
	SettingsPanel = {
		Element = "SettingsPanel", --what we refer to it by
		SettingsBase = "settings", --will look for settings this, so settings_<setting>
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			--their suffix is the SettingsBase, so settings here will equate to settings_*
		},

		--called after initialized
		PostInit = function(panel, key, settings)
			panel:FillPropertySheet({
				Server = LydsPlayer.AdminSettings or {},
				Client = LydsPlayer.Settings or {}
			})
			panel:MakePopup()

			--refreshes
			panel.OnClose = function(self)

				if ( LydsPlayer.LocalPlayer:IsAdmin() and self.Changed) then
					LydsPlayer.CreateWarningBox("Warning!","Admin settings hasnt been saved! please make sure everythings been saved or press close again to ignore")
					self.Changed = false
					panel:Show()
				else
					if (self.Edited or self.Clicked) then
						RunConsoleCommand("media_refresh_cl")
					else
						if (settings.Hide.Value == false ) then
							LydsPlayer.CreateWarningBox("Warning!","youtube_settings_hide is false so settings will always be visible")
							panel:Show()
						end
					end
				end
			end

			if (settings.Hide.Value == false ) then
				panel:Show()
			end
		end
	},

	--Admin Panel
	AdminPanel = {
		Element = "AdminPanel",
		SettingsBase = "admin",
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
	--Preset preview panel
	PresetPreview = {
		Element = "PresetPreviewWindow",
		SettingsBase = "settings",
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:Hide()
		end
	},
	--Warning Message Box
	WarningBox = {
		Preloaded = false, --this won't be created and "hidden", instead it'll be created on demand
		Element = "WarningBox",
		SettingsBase = "warning",
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

	--Success Message Box
	SuccessBox = {
		Preloaded = false,
		Element = "SuccessBox",
		SettingsBase = "success",
		Draggable = true,
		Settings = {

		},
		PostInit = function(panel, key, settings)
			panel:Show()
			panel:MakePopup()
		end
	},
	--Success Message Box
	OptionBox = {
		Preloaded = false,
		Element = "OptionBox",
		SettingsBase = "warning",
		Draggable = true,
		Settings = {

		},
		PostInit = function(panel, key, settings)
			panel:Show()
			panel:MakePopup()
		end
	},
	SearchPanel = {
		Element = "SearchPanel",
		SettingsBase = "search",
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

	--Player Panel
	PlayerPanel = {
		Element = "PlayerPanel",
		SettingsBase = "player",
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_Constant = "show_constantly",
			Context = "show_in_context",
			Scoreboard = "show_in_scoreboard",
			Show_New_Constant = "show_current_video_constantly",
			Muted = "mute",
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()

			if (settings.Hide.Value) then
				panel:Hide()
				return
			end

			if (!table.IsEmpty(LydsPlayer.CurrentVideo)) then
				panel:SetVideo(LydsPlayer.CurrentVideo)

				if (settings.Show_New_Constant.Value or settings.Show_Constant.Value) then
					panel:Show()
				else
					panel:Hide()
				end
			else
				if (settings.Show_Constant.Value) then
					panel:Show()
				elseif ( settings.Context.Value or settings.Scoreboard.Value ) then
					panel:Hide()
				end
			end
		end,
		OnContext =  function(panel, key, settings, opened)
			panel:MakePopup()
			panel:SetKeyboardInputEnabled(false)
			panel:SetMouseInputEnabled(opened)

			if (settings.Hide.Value) then
				panel:Hide()
				return
			end

			if (settings.Show_Constant.Value) then
				panel:Show()
				return
			end

			if (!table.IsEmpty(LydsPlayer.CurrentVideo) and settings.Show_New_Constant.Value ) then
				panel:Show()
				return
			end

			if (settings.Context.Value) then
				panel:SetVisible(opened)
			end
		end,
		OnScoreboard =  function(panel, key, settings, opened)
			panel:MakePopup()
			panel:SetKeyboardInputEnabled(false)
			panel:SetMouseInputEnabled(opened)

			if (settings.Hide.Value) then
				panel:Hide()
				return
			end

			if (settings.Show_Constant.Value) then
				panel:Show()
				return
			end

			if (!table.IsEmpty(LydsPlayer.CurrentVideo) and settings.Show_New_Constant.Value ) then
				panel:Show()
				return
			end

			if (settings.Scoreboard.Value) then
				panel:SetVisible(opened)
			end
		end
	},

	--Vote Panel
	VotePanel = {
		Element = "VotePanel",
		SettingsBase = "vote",
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()
			--nothing needs to be done
			if (table.IsEmpty(LydsPlayer.CurrentVote)) then
				panel:Hide()
			else
				panel:SetVote(LydsPlayer.CurrentVote)
				panel:Show()
			end
		end
	},

	--Playlist Panel
	PlaylistPanel = {
		Element = "PlaylistPanel",
		SettingsBase = "playlist", --setting base, everything in settings array will build off of this string like so playlist_*
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_In_Context = "show_in_context", --this is equiv to playlist_show_in_context
			Show_Constant = "show_constantly", -- you can append a ! to ignore settings base
			Show_In_Scoreboard = "show_in_scoreboard"
		},
		PostInit = function(panel, key, settings)
			panel:UpdatePlaylist()
			panel:Reposition()
			panel:SetPos(ScrW() - settings.Position.Value.X, settings.Position.Value.Y)

			if (table.IsEmpty(LydsPlayer.Playlist) and !settings.Show_Constant.Value ) then
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