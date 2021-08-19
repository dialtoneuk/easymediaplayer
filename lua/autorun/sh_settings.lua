--server settings
local server = {
    MediaPlayer_playlist_limit = {
        Value = 10,
        Comment = "The maximum amount of playlist items allowed at the same"
    },
    MediaPlayer_vote_time = {
        Value = 30,
        Comment = "The maximum amount of playlist items allowed at the same"
    },
    MediaPlayer_announce_admin = {
        Value = true,
        Comment = "Announced in the chat when an admin skips a video"
    },
    MediaPlayer_admin_ignore_limits = {
        Value = true,
        Comment = "Admins can queue as many videos as they like"
    },
    MediaPlayer_announce_video = {
        Value = true,
        Comment = "Announces when a video has begun in the chat"
    },
    MediaPlayer_announce_addition = {
        Value = true,
        Comment = "Announces the addition of a video to the playlist in the chat"
    },
    MediaPlayer_announce_ending = {
        Value = true,
        Comment = "Announces the end of a video in the chat"
    },
    MediaPlayer_announce_count = {
        Value = true,
        Comment = "New vote additions as well as the total votes at the end will be announced in chat"
    },
    MediaPlayer_announce_vote = {
        Value = true,
        Comment = "New votes will be announced in chat"
    },
    MediaPlayer_tips_enabled = {
        Value = true,
        Comment = "Disable tips completely here"
    },
    MediaPlayer_tips_frequency = {
        Value = 180,
        Max = 1000,
        Comment = "In seconds, how frequent tips are"
    },
    MediaPlayer_history_max = {
        Value = 10,
        Max = 50,
        Comment = "How many items from the history to return to the player"
    },
    MediaPlayer_cooldown_enabled = {
        Value = true,
        Comment = "Will turn off cooldowns all together, not recommended"
    },
    MediaPlayer_cooldown_play = {
        Value = 45,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after playing"
    },
    MediaPlayer_cooldown_vote = {
        Value = 60,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after starting a vote",
    },
    MediaPlayer_cooldown_search = {
        Value = 2,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after searching for MediaPlayer",
    },
    MediaPlayer_cooldown_interaction = {
        Value = 180,
        Max = 500,
        Comment = "Cooldown in seconds a player experiences after interacting, so liking or disliking",
    },
    MediaPlayer_command_prefix = {
        Value = "!",
        Comment = "Chat command prefix which is used to execute chat commands, change this if the ! conflicts with something else"
    },
    MediaPlayer_cooldown_history = {
        Value = 1,
        Max = 500,
        Comment = "Cooldown in seconds the player experiences with History page"
    },
    MediaPlayer_cooldown_refreshrate = {
        Value = 1,
        Max = 6,
        Comment = "The time it takes for each cooldown to be decreased by one, by default its a second, you double all cooldowns by setting this to two"
    },
    MediaPlayer_cooldown_command = {
        Value = 1,
        Max = 600,
        Comment = "Cooldown in seconds the player experiences with chat commands"
    },
    MediaPlayer_max_duration = {
        Value = 1200,
        Max = 60000,
        Comment = "The maximum length in seconds a piece of MediaPlayer can be"
    },
    MediaPlayer_max_results = {
        Value = 30,
        Max = 50,
        Comment = "The maximum amount of items a search will return"
    },
    MediaPlayer_ban_after_dislikes = {
        Value = 50,
        Max = 500,
        Min = 0,
        Comment = "After a piece of MediaPlayer has been disliked over this amount it will autoban a video, you can set this to zero if you wish not to ban videos based on dislikes"
    },
    MediaPlayer_custom_tips = {
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
    MediaPlayer_playlist_capacity = {
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
    MediaPlayer_admin_only = {
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
    MediaPlayer_blocked_videos = {
        Value = {
            Video_1 = "DRfidJNts6U"
        }
    },
    MediaPlayer_player_display_video = {
        Value = true,
        Comment = "Displays the video"
    },
    MediaPlayer_playlist_hide_active = {
        Value = false,
        Comment = "If enabled, the current actuve video playing will not be displayed in the playlist"
    },
    MediaPlayer_playlist_auto_resize = {
        Value = true,
        Comment = "Autosize the playlist to fit its elements"
    },
    MediaPlayer_playlist_hide = {
        Value = false,
        Comment = "Hides the playlist completely."
    },
    MediaPlayer_warning_hide = {
        Value = false,
        Comment = "(unused)."
    },
    MediaPlayer_playlist_centered = {
        Value = false,
        Comment = "(unused)"
    },
    MediaPlayer_playlist_invert_position = {
        Value = true,
        Comment = "(unused)"
    },
    MediaPlayer_player_centered = {
        Value = false,
        Comment = "(unused)"
    },
    MediaPlayer_vote_centered = {
        Value = false,
        Comment = "(unused)"
    },
    MediaPlayer_playlist_show_constant = {
        Value = false,
        Comment = "Will show the playlist all the time, not just in the scoreboard and context menu"
    },
    MediaPlayer_settings_centered = {
        Value = false,
        SlowUpdate = 0.75,
        Comment = "Settings window will open center screen"
    },
    MediaPlayer_admin_centered = {
        Value = false,
        Comment = "Admin window will open center screen"
    },
    MediaPlayer_warning_centered = {
        Value = true,
        Comment = "Warning window will open center screen"
    },
    MediaPlayer_search_centered = {
        Value = true,
        Comment = "Search window will open center screen"
    },
    MediaPlayer_playlist_show_in_context = {
        Value = false,
        Comment = "Show the playlist when you press 'c' / go in the context menu"
    },
    MediaPlayer_playlist_show_in_scoreboard = {
        Value = true,
        Comment = "Show the playlist when you press 'tab' / see the scoreboard"
    },
    MediaPlayer_player_hide = {
        Value = false,
        Comment = "Hides the player completely"
    },
    MediaPlayer_player_show_constant = {
        Value = false,
        Comment = "Shows the player constantly"
    },
    MediaPlayer_search_hide = {
        Value = true,
        Comment = "(unused)"
    },
    MediaPlayer_settings_hide = {
        Value = true,
        Comment = "(unused)"
    },
    MediaPlayer_playlist_show_limit = {
        Value = 10,
        Refresh = false,
        Convar = false,
        Comment = "Will only show this amount of videos on the playlist at any given time"
    },
    MediaPlayer_vote_hide = {
        Value = false,
        Comment = "(unused)"
    },
    MediaPlayer_admin_hide = {
        Value = true,
        Comment = "(unused)"
    },
    MediaPlayer_all_show = {
        Value = false,
        Comment = "Useful for designing your look, will display all panels used by Easy MediaPlayer"
    },
    MediaPlayer_player_mute_video = {
        Value = false,
        Comment = "Mutes the audio"
    },
    MediaPlayer_admin_colours = {
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
    MediaPlayer_admin_size = {
        Min = 500,
        Max = 2000,
        Value = {
            Width = 500,
            Height = 500
        }
    },
    MediaPlayer_admin_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    MediaPlayer_settings_colours = {
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
    MediaPlayer_settings_size = {
        Min = 1,
        Max = 2000,
        Value = {
            Width = 715,
            Height = 500,
            Padding = 5
        },
        SlowUpdate = 0.75
    },
    MediaPlayer_settings_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        },
        SlowUpdate = 0.75
    },
    MediaPlayer_base_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
            Padding = 5,
        }
    },
    MediaPlayer_base_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    MediaPlayer_base_colours = {
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
    MediaPlayer_warning_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
        }
    },
    MediaPlayer_warning_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    MediaPlayer_warning_colours = {
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
    MediaPlayer_search_size = {
        Min = 20,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 500,
            RowHeight = 40,
            Padding = 5,
        }
    },
    MediaPlayer_search_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        }
    },
    MediaPlayer_search_colours = {
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
    MediaPlayer_playlist_colours = {
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
    MediaPlayer_playlist_position = {
        Min = 5,
        Max = 2000,
        Value = {
            X = 10,
            Y = 10
        }
    },
    MediaPlayer_playlist_size = {
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
    MediaPlayer_playlist_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    MediaPlayer_player_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    MediaPlayer_settings_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = false
        }
    },
    MediaPlayer_warning_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    MediaPlayer_search_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = false
        }
    },
    MediaPlayer_vote_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    MediaPlayer_admin_options = {
        Min = 1,
        Max = 25,
        Value = {
            BorderThickness = 2,
            DisplayTitle = true
        }
    },
    MediaPlayer_player_position = {
        Min = 5,
        Max = 2000,
        Value = {
            X = 10,
            Y = 10
        }
    },
    MediaPlayer_player_colours = {
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
    MediaPlayer_player_size = {
        Min = 5,
        Max = 1000,
        Value = {
            Width = 500,
            Height = 300,
            LoadingBarHeight = 5
        }
    },
    MediaPlayer_vote_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 520,
            Y = 10
        }
    },
    MediaPlayer_vote_size = {
        Min = 5,
        Max = 400,
        Value = {
            Width = 190,
            Height = 75,
            Padding = 15,
            LoadingBarHeight = 5
        }
    },
    MediaPlayer_vote_colours = {
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
    MediaPlayer_chat_colours = {
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
