local server = {


}

local client = {

	base_size = {
		Min = 20,
		Max = 2000,
		Value = {
			Width = 750,
			Height = 500,
			RowHeight = 40,
			Padding = 5,
		}
	},
	base_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 25,
			Y = 25
		}
	},
	base_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value) --TODO: Optimize to use pre-created colours instead of creating new ones
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = MediaPlayer.Colours.FadedBlack,
			Border = MediaPlayer.Colours.FadedBlack,
			TextColor = MediaPlayer.Colours.FadedWhite,
			ItemBackground = MediaPlayer.Colours.FadedBlack,
			ItemBorder = MediaPlayer.Colours.FadedBlue
		}
	},
	base_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is based off of the current gui_resize_scale value."
	},
	base_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the base panel, you can use this to make things position from the right of the screen instead of the left."
	},
	base_hide = {
		Value = false,
		Comment = "(unused)"
	},
	base_auto_resize = {
		Value = false,
		Comment = "(unused)"
	},
	base_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	}
}

--register our settings
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterBaseSettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)
