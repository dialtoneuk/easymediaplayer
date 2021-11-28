--settings for the votes, success and warning boxes, as well as announcement boxes

local server = {

	vote_default_duration = {
		Value = 30,
		Comment = "How long votes will last for."
	},
}

local client = {

	--

	warning_hide = {
		Value = false,
		Comment = "(unused)."
	},
	success_hide = {
		Value = false,
		Comment = "(unused)."
	},
	success_auto_resize = {
		Value = false,
		Comment = "(unused)."
	},
	success_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	warning_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	vote_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	vote_center_horizontally = {
		Value = false,
		Comment = "Turning this to true will mean that the vote panel is centered horizontally to the screen, the Y position still counts."
	},
	warning_auto_resize = {
		Value = false,
		Comment = "(unused)."
	},
	vote_auto_resize = {
		Value = false,
		Comment = "(unused)."
	},
	vote_invert_position = {
		Value = false,
		Comment = "Inverts the x position of a vote, you can use this to make things position from the right of the screen instead of the left."
	},
	warning_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the warning box, you can use this to make things position from the right of the screen instead of the left."
	},
	success_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the success box, you can use this to make things position from the right of the screen instead of the left."
	},
	vote_centered = {
		Value = false,
		Comment = "(unused)"
	},
	warning_centered = {
		Value = true,
		Comment = "The warning box will open centered to the middle of your screen."
	},
	success_centered = {
		Value = true,
		Comment = "The success box will open centered to the middle of your screen."
	},
	vote_hide = {
		Value = false,
		Comment = "Will disable votes from appearing."
	},
	warning_size = {
		Min = 20,
		Max = 2000,
		Value = {
			Width = 750,
			Height = 500,
			Padding = 5,
		}
	},
	warning_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 25,
			Y = 25
		}
	},
	warning_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value)
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
	success_size = {
		Min = 20,
		Max = 2000,
		Value = {
			Width = 400,
			Height = 400,
			Padding = 5,
		}
	},
	success_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 25,
			Y = 25
		}
	},
	success_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value)
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
	warning_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	},
	success_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	},
	vote_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	},
	vote_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 520,
			Y = 10
		}
	},
	vote_size = {
		Min = 5,
		Max = 400,
		Value = {
			Width = 190,
			Height = 75,
			Padding = 15,
			LoadingBarHeight = 5
		}
	},
	vote_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value)
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = MediaPlayer.Colours.FadedBlack,
			Border = MediaPlayer.Colours.FadedBlack,
			TextColor = MediaPlayer.Colours.Black,
			LoadingBarBackground = MediaPlayer.Colours.Red
		}
	}
}

hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterPanelsSettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)