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
				return LydsPlayer.TableToColour(value) --TODO: Optimize to use pre-created colours instead of creating new ones
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = LydsPlayer.Colours.FadedBlack,
			Border = LydsPlayer.Colours.FadedBlack,
			TextColor = LydsPlayer.Colours.FadedWhite,
			ItemBackground = LydsPlayer.Colours.FadedBlack,
			ItemBorder = LydsPlayer.Colours.FadedBlue
		}
	},
	base_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = LydsPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	base_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the base panel, you can use this to make things position from the right of the screen instead of the left."
	},
	base_hide = {
		Value = false,
		Comment = "(unused)"
	},
	base_centered = {
		Value = true,
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
hook.Add("LydsPlayer.SettingsLoaded","LydsPlayer.RegisterBaseSettings", function()
	LydsPlayer.RegisterSettings(server, client)
end)
