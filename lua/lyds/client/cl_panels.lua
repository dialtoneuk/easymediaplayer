--[[
  These are the panels which are used by this addon, they are defined here
]]--

MediaPlayer.Panels = {
	SettingsPanel = {
		Element = "SettingsPanel",
		SettingsBase = "media_settings", --will default to media_default
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel, key, settings)
			panel:FillPropertySheet({
				Server = MediaPlayer.AdminSettings or {},
				Client = MediaPlayer.Settings or {}
			})
			panel:MakePopup()

			--refreshes
			panel.OnClose = function(self)
				RunConsoleCommand("media_create_cl")
				self:Hide()
			end

			if (settings.Hide.Value == false ) then
				panel:Show()
			end
		end
	},
	AdminPanel = {
		Element = "AdminPanel",
		SettingsBase = "media_admin",
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
		SettingsBase = "media_warning",
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
	SuccessBox = {
		Preloaded = false,
		Element = "SuccessBox",
		SettingsBase = "media_success",
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
		SettingsBase = "media_search",
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
		SettingsBase = "media_player",
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_Constant = "show_constant",
			Context = "show_in_context",
			Scoreboard = "show_in_scoreboard",
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()

			if (!table.IsEmpty(MediaPlayer.CurrentVideo)) then
				panel:SetVideo(MediaPlayer.CurrentVideo)

				if (settings.Show_Constant.Value or !settings.Hide.Value and !settings.Context.Value and !settings.Scoreboard.Value) then
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

			if (settings.Context.Value and !settings.Show_Constant.Value) then
				panel:SetVisible(opened)
			end
		end,
		OnScoreboard =  function(panel, key, settings, opened)
			panel:SetKeyboardInputEnabled(opened)
			panel:SetMouseInputEnabled(opened)

			if (settings.Scoreboard.Value and !settings.Show_Constant.Value) then
				panel:SetVisible(opened)
			end
		end
	},
	VotePanel = {
		Element = "VotePanel",
		SettingsBase = "media_vote",
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
		SettingsBase = "media_playlist", --setting base, everything in settings array will build off of this string like so media_playlist_*
		Draggable = false,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
			Show_In_Context = "show_in_context", --this is equiv to media_playlist_show_in_context
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