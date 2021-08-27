local server = {

	player_max_videos = {
		Value = 2,
		Max = 20,
		Comment = "How many videos a player can have on the playlist at an given time, regardless of platform."
	},
	player_disable_mp3 = {
		Value = false,
		Comment = "Disables the ability for players to post mp3s but does not restrict admins."
	},
	player_disable_youtube = {
		Value = false,
		Comment = "Disables the ability for players to post youtube videos but does not restrict admins."
	}
}

local client = {

	player_display_video = {
		Value = true,
		Comment = "Disabling this will make the video/audio player invisible."
	},
	player_invert_position = {
		Value = false,
		Comment = "Inverts the x position of the player, you can use this to make things position from the right of the screen instead of the left."
	},
	player_auto_resize = {
		Value = true,
		Comment = "Inverts the x position of the player, you can use this to make things position from the right of the screen instead of the left."
	},
	player_resize_scale = {
		Value = 1,
		Refresh = false,
		Type = MediaPlayer.Type.FLOAT,
		Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
	},
	player_centered = {
		Value = false,
		Comment = "(unused)"
	},
	player_show_current_video = {
		Value = true,
		Comment = "Diabling this will keep the player hidden even if a new video is playing. You would enable this if you were looking to stop the player reappearing, always keeping it hidden, except for instance in the scoreboard or context menu."
	},
	player_show_current_video_constantly = {
		Value = true,
		Comment = "Disabling this will mean that the player does not ignore other show settings when a video is active and function properly. You would disable this if you were looking to keep your player always hidden except for in the scoreboard or context menu."
	},
	player_show_in_context = {
		Value = false,
		Comment = "Enabling this will make the player visible in the context menu."
	},
	player_show_in_scoreboard = {
		Value = true,
		Comment = "Enabling this will make the player visible in the scoreboard menu."
	},
	player_hide = {
		Value = false,
		Comment = "Enabling this will disable the player from being visible."
	},
	player_show_constantly = {
		Value = false,
		Comment = "Enabling this show the player in all areas of the game (scoreboard, hud, context)."
	},
	player_mute = {
		Value = false,
		Comment = "Enabling this will mute the audio completely."
	},
	player_volume = {
		Value = 100,
		Min = 0,
		Max = 100,
		Comment = "Sets the volume of the player."
	},
	player_options = {
		Min = 1,
		Max = 25,
		Value = {
			BorderThickness = 2,
			DisplayTitle = true
		}
	},
	player_position = {
		Min = 5,
		Max = 2000,
		Value = {
			X = 10,
			Y = 10
		}
	},
	player_colours = {
		Value = {
			__unpack = function(self, index, value) --called when unpacking from save json
				return MediaPlayer.TableToColour(value)
			end,
			__pack = function(self, index, value) --called when packing data into json.
				return value
			end,
			Background = MediaPlayer.Colours.FadedBlack,
			TextColor = MediaPlayer.Colours.White,
			Border = MediaPlayer.Colours.FadedBlack,
			SecondaryBorder = MediaPlayer.Colours.FadedBlack,
			LoadingBarBackground = MediaPlayer.Colours.Red
		}
	},
	player_size = {
		Min = 1,
		Max = 1000,
		Value = {
			Width = 500,
			Height = 300,
			Padding = 2,
			LoadingBarHeight = 5
		}
	}
}

--register our settings
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterPlayerSettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)
