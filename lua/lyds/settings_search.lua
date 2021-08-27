local server = {

	search_result_count = {
		Value = 30,
		Max = 30,
		Comment = "How many search results will be returned when queries are made inside the search panel (max of 50)."
	}
}

local client = {

	search_centered = {
		Value = true,
		Comment = "The search window will open centered to the middle of your screen."
	},
	search_page_limit = {
		Value = 10,
		Comment = "How many items to show per page"
	},
	search_auto_resize = {
		Value = true,
		Comment = "The search panel will scale relative to gui_resize_scale."
	},
	search_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the search panel, you can use this to make things position from the right of the screen instead of the left."
	},
	search_hide = {
		Value = true,
		Comment = "(unused)"
	},
	search_column_count = {
		Value = 4,
		Max = 50,
		Comment = "How many search results will be returned when queries are made inside the search panel (max of 50)."
	},
	search_column_width = {
		Value = 150,
		Max = 500,
		Comment = "How many search results will be returned when queries are made inside the search panel (max of 50)."
	},
	search_resize_scale = {
		Value = 0.8,
		Max = 2.0,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	search_size = {
		Min = 20,
		Max = 2000,
		Value = {
			Width = 750,
			Height = 500,
			RowHeight = 40,
			Padding = 5,
		}
	},
	search_position = {
		Min = 10,
		Max = 2000,
		Value = {
			X = 25,
			Y = 25
		}
	},
	search_colours = {
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
			ItemBorder = MediaPlayer.Colours.Blue,
			HeaderBackground = MediaPlayer.Colours.FadedBlack,
			HeaderBorder = MediaPlayer.Colours.Gray
		}
	},
	search_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = false
		}
	}
}

--register our settings
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterSearchSettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)