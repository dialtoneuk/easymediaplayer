--[[
  These are the panels which are used by this addon, they are defined here
]]--

MEDIA.Panels = {
	SettingsPanel = {
		Element = "SettingsPanel",
		SettingsBase = "media_settings", --will default to media_default
		Draggable = true,
		Admin = false,
		Settings = {
			--can define extra settings here
			--size, is centered and show is implicit
		},
		PostInit = function(panel)
			panel:FillPropertySheet({
				Server = MEDIA.AdminSettings or {},
				Client = MEDIA.Settings or {}
			})
			panel:MakePopup()
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
		},
		PostInit = function(panel, key, settings)
			panel:Reposition()

			if (!table.IsEmpty(MEDIA.CurrentVideo)) then
				panel:SetVideo(MEDIA.CurrentVideo)
				panel:Show()
			else
				if (settings.Hide.Value) then
					panel:Hide()
				else
					panel:Show()
				end
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
			if (table.IsEmpty(MEDIA.CurrentVote)) then
				panel:Hide()
			else
				panel:SetVote(MEDIA.CurrentVote)
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
			Show_Constant = "show_constant",
			Show_In_Scoreboard = "show_in_scoreboard"
		},
		PostInit = function(panel, key, settings)
			panel:UpdatePlaylist()
			panel:Reposition()
			panel:SetPos(ScrW() - settings.Position.Value.X, settings.Position.Value.Y)

			if (settings.Show_Constant.Value) then
				panel:Show()
				return
			end

			if ( table.IsEmpty(MEDIA.Playlist) or settings.Hide.Value) then
				panel:Hide()
			else
				panel:Show()
			end
		end,
		OnContext = function(panel, key, settings, opened)
			if ((!opened or !settings.Show_In_Context.Value ) or settings.Hide.Value) then
				panel:Hide()
				return
			end

			panel:Show()
		end,
		OnScoreboard = function(panel, key, settings, opened)
			if (opened and !settings.Show_In_Scoreboard.Value) then
				return
			end

			MEDIA.LoadedPanels[key].OnContext(panel,key,settings,opened)
		end
	},
}