--server settings
local server = {
    media_playlist_limit = {
        Value = 10,
        Comment = "The maxium amount of videos the server will broadcast at any given time to all players, regardless of how many playlist items the client is set to draw"
    },
    media_vote_time = {
        Value = 30,
        Comment = "The maximum amount of playlist items allowed at the same"
    },
    media_announce_admin = {
        Value = true,
        Comment = "Announced in the chat when an admin skips a video"
    },
    media_admin_ignore_limits = {
        Value = true,
        Comment = "Admins can queue as many videos as they like"
    },
    media_announce_video = {
        Value = true,
        Comment = "Announces when a video has begun in the chat"
    },
    media_announce_addition = {
        Value = true,
        Comment = "Announces the addition of a video to the playlist in the chat"
    },
    media_announce_ending = {
        Value = true,
        Comment = "Announces the end of a video in the chat"
    },
    media_announce_count = {
        Value = true,
        Comment = "New vote additions as well as the total votes at the end will be announced in chat"
    },
    media_announce_vote = {
        Value = true,
        Comment = "New votes will be announced in chat"
    },
    media_tips_enabled = {
        Value = true,
        Comment = "Disable tips completely here"
    },
    media_tips_frequency = {
        Value = 180,
        Max = 1000,
        Comment = "In seconds, how frequent tips are"
    },
    media_history_max = {
        Value = 10,
        Max = 50,
        Comment = "How many items from the history to return to the player"
    },
    media_cooldown_enabled = {
        Value = true,
        Comment = "Will turn off cooldowns all together, not recommended"
    },
    media_cooldown_play = {
        Value = 45,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after playing"
    },
    media_cooldown_vote = {
        Value = 60,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after starting a vote",
    },
    media_cooldown_search = {
        Value = 2,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after searching for MediaPlayer",
    },
    media_cooldown_interaction = {
        Value = 180,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after interacting, so liking or disliking",
    },
    media_command_prefix = {
        Value = "!",
        Comment = "Chat command prefix which is used to execute chat commands, change this if the ! conflicts with something else"
    },
    media_cooldown_history = {
        Value = 1,
        Max = 500,
        Comment = "Cooldown in seconds the player experiences with History page"
    },
    media_cooldown_refreshrate = {
        Value = 1,
        Max = 6,
        Comment = "The time it takes for each cooldown to be decreased by one, by default its a second, you double all cooldowns by setting this to two"
    },
    media_cooldown_command = {
        Value = 1,
        Max = 600,
        Comment = "Cooldown in seconds the player experiences with chat commands"
    },
    media_max_duration = {
        Value = 1200,
        Max = 60000,
        Comment = "The maximum length in seconds a piece of MediaPlayer can be"
    },
    media_max_results = {
        Value = 30,
        Max = 50,
        Comment = "The maximum amount of items a search will return"
    },
    media_ban_after_dislikes = {
        Value = 50,
        Max = 500,
        Min = 0,
        Comment = "After a piece of MediaPlayer has been disliked over this amount it will autoban a video, you can set this to zero if you wish not to ban videos based on dislikes"
    },
    media_custom_tips = {
        Value = {
            "this is a tip",
            "so is this"
        },
        Max = 20, --max elements
        Custom = true
    },
    player_playlist_max = {
        Value = 2,
        Max = 20,
        Comment = "The max amount of videos a player can submit to the playlist"
    },
    media_playlist_capacity = {
        Value = 64,
        Max = 248,
        Comment = "The max amount of videos the playlist can hold"
    },
    pointshop_enabled = {
        Value = false,
        Comment = "Enable this if you are using pointshop"
    },
    pointshop_cost = {
        Value = 2,
        Max = 20,
        Comment = "Only works if pointshop is installed, if it is, this is price in coins to submit MediaPlayer"
    },
    youtube_deep_check = {
        Value = false,
        Comment = "Will use an api request up when verifying a videos existence"
    },
    youtube_enabled = {
        Value = false,
        Comment = "Since youtube only works on the Chromium branch, it is advised this disabled out right!"
    },
    youtube_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "Head over to google dashboard and create API credientials which have access to the Youtube Data API (version 3)"
    },
    dailymotion_enabled = {
        Value = true,
        Comment = "Will disable dailymotion videos from being supported"
    },
    dailymotion_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "TODO: Fill"
    },
    soundcloud_enabled = {
        Value = true,
        Comment = "Will disable soundcloud music from being supported"
    },
    soundcloud_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "TODO: Fill"
    },
    allow_custom_mp3 = {
        Value = false,
        Comment = "TODO: Fill"
    },
    media_admin_only = {
        Value = true,
        Comment = "Only admins can playlist things"
    }
}

--client settings
local client = {
    youtube_client_api_key = {
        Value = "(unimplemented)",
        Comment = "(unimplemented)"
    },
    dailymotion_client_api_key = {
        Value = "(unimplemented)",
        Comment = "(unimplemented)"
    },
    media_blocked_videos = {
        Value = {
            Video_1 = "DRfidJNts6U"
        }
    },
    media_player_display_video = {
        Value = true,
        Comment = "Displays the video"
    },
    media_playlist_hide_active = {
        Value = false,
        Comment = "If enabled, the current actuve video playing will not be displayed in the playlist"
    },
    media_playlist_auto_resize = {
        Value = true,
        Comment = "Autosize the playlist to fit its elements"
    },
    media_playlist_hide = {
        Value = false,
        Comment = "Hides the playlist completely."
    },
    media_warning_hide = {
        Value = false,
        Comment = "(unused)."
    },
    media_success_hide = {
        Value = false,
        Comment = "(unused)."
    },
    media_playlist_centered = {
        Value = false,
        Comment = "(unused)"
    },
    media_playlist_invert_position = {
        Value = true,
        Comment = "(unused)"
    },
    media_player_centered = {
        Value = false,
        Comment = "(unused)"
    },
    media_vote_centered = {
        Value = false,
        Comment = "(unused)"
    },
    presets_allow_default = {
        Value = true,
        Comment = "Allows a servers default preset to override your settings"
    },
    media_playlist_show_constant = {
        Value = false,
        Comment = "Will show the playlist all the time, not just in the scoreboard and context menu"
    },
    media_settings_centered = {
        Value = false,
        Refresh = false,
        Comment = "Settings window will open center screen"
    },
    media_admin_centered = {
        Value = false,
        Comment = "Admin window will open center screen"
    },
    media_warning_centered = {
        Value = true,
        Comment = "Warning window will open center screen"
    },
    media_success_centered = {
        Value = true,
        Comment = "Warning window will open center screen"
    },
    media_search_centered = {
        Value = true,
        Comment = "Search window will open center screen"
    },
    media_playlist_show_in_context = {
        Value = false,
        Comment = "Show the playlist when you press 'c' / go in the context menu"
    },
    media_playlist_show_in_scoreboard = {
        Value = true,
        Comment = "Show the playlist when you press 'tab' / see the scoreboard"
    },
    media_player_hide = {
        Value = false,
        Comment = "Hides the player completely"
    },
    media_player_show_constant = {
        Value = false,
        Comment = "Shows the player constantly"
    },
    media_search_hide = {
        Value = true,
        Comment = "(unused)"
    },
    media_settings_hide = {
        Value = true,
        Comment = "Will keep the settings window open forever (recommended when designing looks)"
    },
    media_playlist_show_limit = {
        Value = 10,
        Refresh = false,
        Convar = false,
        Comment = "Will only show this amount of videos on the playlist at any given time"
    },
    media_vote_hide = {
        Value = false,
        Comment = "(unused)"
    },
    media_admin_hide = {
        Value = true,
        Comment = "(unused)"
    },
    media_all_show = {
        Value = false,
        Comment = "Useful for designing your look, will display all panels used by Easy MediaPlayer"
    },
    media_player_mute_video = {
        Value = false,
        Comment = "Mutes the audio"
    },
    media_admin_colours = {
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
    media_admin_size = {
        Min = 500,
        Max = 2000,
        Value = {
            Width = 500,
            Height = 500
        }
    },
    media_admin_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    media_settings_colours = {
        Value = {
            __unpack = function(self, index, value) --called when unpacking from save json
                return MediaPlayer.TableToColour(value)
            end,
            __pack = function(self, index, value) --called when packing data into json.
                return value
            end,
            Background = MediaPlayer.Colours.FadedBlack,
            Border = MediaPlayer.Colours.FadedBlack,
            SecondaryBorder = MediaPlayer.Colours.FadedGray,
            TextColor = MediaPlayer.Colours.White
        }
    },
    media_settings_size = {
        Min = 1,
        Max = 2000,
        Value = {
            Width = 715,
            Height = 715,
            Padding = 5
        },
        Refresh = false
    },
    media_settings_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        },
        Refresh = false
    },
    media_base_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
            Padding = 5,
        }
    },
    media_base_hide = {
        Value = false,
        Comment = "(unused)"
    },
    media_base_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    media_base_colours = {
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
    media_warning_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
        }
    },
    media_warning_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    media_warning_colours = {
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
    media_success_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 400,
            Height = 400,
            RowHeight = 40,
        }
    },
    media_success_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    media_success_colours = {
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
    media_search_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
            Padding = 5,
        }
    },
    media_search_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    media_search_colours = {
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
    media_playlist_colours = {
        Value = {
            __unpack = function(self, index, value) --called when unpacking from save json
                return MediaPlayer.TableToColour(value)
            end,
            __pack = function(self, index, value) --called when packing data into json.
                return value
            end,
            Background = MediaPlayer.Colours.FadedBlack,
            TextColor = MediaPlayer.Colours.White,
            ItemActiveBackground = MediaPlayer.Colours.Red,
            ItemBackground = MediaPlayer.Colours.FadedBlack,
            ItemBorder = MediaPlayer.Colours.FadedBlack,
            Border = MediaPlayer.Colours.FadedBlack
        }
    },
    media_playlist_position = {
        Min = 5,
        Max = 2000,
        Value = {
            X = 10,
            Y = 10
        }
    },
    media_playlist_size = {
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
    media_playlist_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_player_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_settings_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = false
        }
    },
    media_warning_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_success_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_search_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = false
        }
    },
    media_vote_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_admin_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    media_player_position = {
        Min = 5,
        Max = 2000,
        Value = {
            X = 10,
            Y = 10
        }
    },
    media_player_colours = {
        Value = {
            __unpack = function(self, index, value) --called when unpacking from save json
                return MediaPlayer.TableToColour(value)
            end,
            __pack = function(self, index, value) --called when packing data into json.
                return value
            end,
            Background = MediaPlayer.Colours.FadedBlack,
            TextColor = MediaPlayer.Colours.White,
            ItemActiveBackground = MediaPlayer.Colours.Red,
            ItemBackground = MediaPlayer.Colours.FadedBlack,
            ItemBorder = MediaPlayer.Colours.FadedBlack,
            Border = MediaPlayer.Colours.FadedBlack,
            SecondaryBorder = MediaPlayer.Colours.FadedBlack,
            LoadingBarBackground = MediaPlayer.Colours.Red
        }
    },
    media_player_size = {
        Min = 5,
        Max = 1000,
        Value = {
            Width = 500,
            Height = 300,
            LoadingBarHeight = 5
        }
    },
    media_vote_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 520,
            Y = 10
        }
    },
    media_vote_size = {
        Min = 5,
        Max = 400,
        Value = {
            Width = 190,
            Height = 75,
            Padding = 15,
            LoadingBarHeight = 5
        }
    },
    media_vote_colours = {
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
    },
    media_chat_colours = {
        Value = {
            __unpack = function(self, index, value) --called when unpacking from save json
                return MediaPlayer.TableToColour(value)
            end,
            __pack = function(self, index, value) --called when packing data into json.
                return value
            end,
            PrefixColor = MediaPlayer.Colours.Red,
            TextColor = MediaPlayer.Colours.White
        }
    }
}

--register our settings
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterSettings", function()
    MediaPlayer.RegisterSettings(server, client)
end)
