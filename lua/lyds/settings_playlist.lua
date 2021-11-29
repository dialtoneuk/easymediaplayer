--settings for the playlist on both the admin and clients side

local server = {

	playlist_broadcast_limit = {
		Value = 50,
		Dangerous = true,
		Comment = "This is the maximum amount of videos that the playlist will broadcast in a net message, turn this down if you are experiencing overflow errors."
	},
	playlist_capacity = {
		Value = 64,
		Max = 248,
		Comment = "The total amount of videos the playlist can hold."
	},
}

local client = {

	playlist_hide_active = {
		Value = false,
		Comment = "Enabling this will hide the current active video from being displayed inside the playlist."
	},
	playlist_auto_resize = {
		Value = true,
		Comment = "Disabling will disable the playlists rescaling functionality and make it static."
	},
	playlist_resize_scale = {
		Value = 1,
		Max = 2.0,
		Type = LydsPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value.",
		Refresh = false,
	},
	playlist_hide = {
		Value = false,
		Comment = "Enabling this will hide the playlist from the screen completely."
	},
	playlist_centered = {
		Value = false,
		Comment = "(unused)"
	},
	playlist_invert_position = {
		Value = true,
		Comment = "Inverts the x position of the playlist, you can use this to make things position from the right of the screen instead of the left."
	},
	playlist_show_constantly = {
		Value = false,
		Comment = "Enabling this will show the playlist in all areas of the ui (scoreboard, hud, context)."
	},
	playlist_show_in_context = {
		Value = false,
		Comment = "Enabling this will make the playlist visible in the context menu."
	},
	playlist_show_in_scoreboard = {
		Value = true,
		Comment = "Enabling this will make the playlist visible in the scoreboard menu."
	},
	playlist_display_limit = {
		Value = 10,
		Min = 2,
		Max = 40,
		Refresh = false,
		Convar = false,
		Comment = "How many videos to display inside the playlist, will add a panel after this amount with the total videos currently on the playlist."
	},
	playlist_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return LydsPlayer.TableToColour(value)
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = LydsPlayer.Colours.FadedBlack,
			TextColor = LydsPlayer.Colours.White,
			ItemActiveBackground = LydsPlayer.Colours.Red,
			ItemBackground = LydsPlayer.Colours.FadedBlack,
			ItemBorder = LydsPlayer.Colours.FadedBlack,
			Border = LydsPlayer.Colours.FadedBlack,
			SecondaryBorder = LydsPlayer.Colours.FadedBlack,
		}
	},
	playlist_position = {
		Min = 5,
		Max = 2000,
		Value = {
			X = 10,
			Y = 10
		}
	},
	playlist_size = {
		Min = 1,
		Max = 1000,
		Value = {
			Width = 350,
			Height = 100,
			RowHeight = 80,
			Padding = 5,
			RowSpacing = 10
		}
	},
	playlist_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	},
}

hook.Add("LydsPlayer.SettingsLoaded","LydsPlayer.RegisterPlaylistSettings", function()
	LydsPlayer.RegisterSettings(server, client)
end)
