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
		Max = 10,
		Min = 1,
		Comment = "Defines how many vertical columns will be present in the search area.",
		SlowUpdate = 1
	},
	search_column_width = {
		Value = 150,
		Max = 500,
		Comment = "(unused)."
	},
	search_resize_scale = {
		Value = 0.8,
		Max = 2.0,
		Refresh = false,
		Type = LydsPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	search_size = {
		Min = 20,
		Max = 2000,
		Value = {
			Width = 750,
			Height = 500,
			RowHeight = 40,
			SecondaryRowHeight = 200,
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
				return LydsPlayer.TableToColour(value)
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = LydsPlayer.Colours.FadedBlack,
			Border = LydsPlayer.Colours.FadedBlack,
			TextColor = LydsPlayer.Colours.FadedWhite,
			ItemBackground = LydsPlayer.Colours.FadedBlack,
			ItemBorder = LydsPlayer.Colours.Blue,
			HeaderBackground = LydsPlayer.Colours.FadedBlack,
			HeaderBorder = LydsPlayer.Colours.Gray
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
hook.Add("LydsPlayer.SettingsLoaded","LydsPlayer.RegisterSearchSettings", function()
	LydsPlayer.RegisterSettings(server, client)
end)
