local server = {

	admin_only = {
		Value = false,
		Comment = "Admins are the only ones which are able to submit videos."
	},
	admin_ignore_limits = {
		Value = true,
		Comment = "Admins are not restricted by player_max_videos."
	},
}

local client = {

	admin_hide = {
		Value = true,
		Comment = "(unused)"
	},
	admin_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the admin panel, you can use this to make things position from the right of the screen instead of the left."
	},
	admin_centered = {
		Value = false,
		Comment = "The admin window will open centered to the middle of your screen."
	},
	admin_size = {
		Min = 500,
		Max = 2000,
		Value = {
			Width = 500,
			Height = 500
		}
	},
	admin_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 25,
			Y = 25
		}
	},
	admin_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value)
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = MediaPlayer.Colours.FadedBlack,
			Border = MediaPlayer.Colours.FadedBlack,
			ButtonBackground = MediaPlayer.Colours.FadedRed,
			ButtonBorder = MediaPlayer.Colours.Red,
			TextColor = MediaPlayer.Colours.Black
		}
	},
	admin_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	}
}

--register our settings
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterAdminSettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)
