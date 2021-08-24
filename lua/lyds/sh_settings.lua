--server settings

local server = {
    media_playlist_limit = {
        Value = 50,
        Comment = "This is the maximum amount of videos that the playlist will broadcast in a net message, turn this down if you are experiencing overflow errors."
    },
    media_vote_time = {
        Value = 30,
        Comment = "How long votes will last for."
    },
    media_announce_admin = {
        Value = true,
        Comment = "Announce to the server when an admin skips or removes videos from the playlist."
    },
    media_admin_ignore_limits = {
        Value = true,
        Comment = "Admins are not restricted by player_playlist_max."
    },
    media_announce_video = {
        Value = true,
        Comment = "Announce to the server when a new video has begun."
    },
    media_announce_addition = {
        Value = true,
        Comment = "Announce to the server when a new video has been added to the playlist."
    },
    media_announce_ending = {
        Value = true,
        Comment = "Announce to the server when a video has come to its end."
    },
    media_announce_spawn = {
        Value = true,
        Comment = "Announce to the player that the server is running this plugin."
    },
    media_announce_count = {
        Value = true,
        Comment = "Announce to the server when a vote has gained a new vote."
    },
    media_announce_vote = {
        Value = true,
        Comment = "Announce the creation of new votes to the server."
    },
    media_announce_likes = {
        Value = true,
        Comment = "Announce to the server when a player has liked a video."
    },
    media_announce_dislikes = {
        Value = true,
        Comment = "Announce to the server when a player has disliked a video."
    },
    media_announce_settings = {
        Value = true,
        Comment = "Announce to all admins online when edits to the servers settings are made."
    },
    media_tips_enabled = {
        Value = true,
        Comment = "Tips will be posted into the chats of players."
    },
    media_tips_frequency = {
        Value = 600, --every 10 mins
        Max = 1000,
        Comment = "In seconds, how frequent tips will be posted into the chats of players."
    },
    media_history_max = {
        Value = 10,
        Max = 50,
        Comment = "The amount of items to return to the player when they request the servers history inside the search panel."
    },
    media_cooldown_enabled = {
        Value = true,
        Comment = "Users will recieve cooldowns (it is recommended that you keep this enabled)"
    },
    media_cooldown_play = {
        Value = 45,
        Max = 500,
        Comment = "How many seconds the player has to wait once submitting a video."
    },
    media_cooldown_vote = {
        Value = 10,
        Max = 500,
        Comment = "How many seconds the player has to wait once starting a vote.",
    },
    media_cooldown_search = {
        Value = 1,
        Max = 10,
        Comment = "How many seconds the player has to wait after searching for media. (its recommended you keep this at its current value).",
    },
    media_cooldown_interaction = {
        Value = 180,
        Max = 500,
        Comment = "How many seconds the player has to wait after liking or disliking a video. (players can only like/dislike the current video a single time anyway).",
    },
    media_cooldown_history = {
        Value = 1,
        Max = 500,
        Comment = "How many seconds the player has to wait after requesting server history. (its recommended you keep this at its current value).",
    },
    media_cooldown_refreshrate = {
        Value = 1,
        Max = 6,
        Comment = "Setting this to a value of two will effectively double the time all cooldowns take, setting it to three will tripple and so forth. Use this to change the server to slowmode temporarily."
    },
    media_cooldown_command = {
        Value = 1,
        Max = 600,
        Comment = "How many seconds the player has to wait between using chat commmands."
    },
    media_command_prefix = {
        Value = "!",
        Comment = "This is the prefix which Easy Mediaplayer will attach to its chat commands. Change this to another character if it conflicts with one of your other addons."
    },
    media_max_duration = {
        Value = 1200,
        Max = 60000,
        Comment = "Roughly in seconds how long a piece of media can be no matter the platform."
    },
    media_max_results = {
        Value = 30,
        Max = 50,
        Comment = "How many search results will be returned when queries are made inside the search panel (max of 50)."
    },
    media_ban_after_dislikes = {
        Value = 50,
        Max = 500,
        Min = 0,
        Comment = "After a piece of media has been disliked over the ammount defined it will be added automatically to the ban list. You can set this to zero if you wish not to ban videos based on dislikes."
    },
    media_custom_tips = {
        Value = {
            "this is a tip",
            "so is this"
        },
        Comment = "(editing coming soon)",
        Max = 20, --max elements
        Custom = true
    },
    player_playlist_max = {
        Value = 2,
        Max = 20,
        Comment = "How many videos a player can have on the playlist at an given time, regardless of platform."
    },
    media_playlist_capacity = {
        Value = 64,
        Max = 248,
        Comment = "The total amount of videos the playlist can hold."
    },
    pointshop_enabled = {
        Value = false,
        Comment = "Players will be charged pointshop points in exchanging for putting videos into the playlist."
    },
    pointshop_cost = {
        Value = 2,
        Max = 20,
        Comment = "How much it costs for a video to be added to the playlist."
    },
    youtube_deep_check = {
        Value = false,
        Comment = "Will use an API call to check for a videos existience, can help fix some videos not working."
    },
    youtube_enabled = {
        Value = false,
        Comment = "Enables youtube as being a supported media type."
    },
    youtube_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "Head over to google dashboard and create API credientials which have access to the Youtube Data API (version 3)"
    },
    dailymotion_enabled = {
        Value = true,
        Comment = "Enables dailymotion as being a supported media type."
    },
    dailymotion_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "TODO: Fill"
    },
    soundcloud_enabled = {
        Value = true,
        Comment = "Enables soundcloud as being a supported media type."
    },
    soundcloud_api_key = {
        Value = "REPLACE WITH YOUR OWN",
        Comment = "TODO: Fill"
    },
    mp3_enabled = {
        Value = false,
        Comment = "Enables mp3 submissions. (please read the readme.md)."
    },
    mp3_https_only = {
        Value = true,
        Comment = "Only allows https links to be submitted."
    },
    admin_only = {
        Value = false,
        Comment = "Admins are the only ones which are able to submit videos."
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
        },
        Custom = true,
        Comment = "(editing coming soon)"
    },
    media_player_display_video = {
        Value = true,
        Comment = "Disabling this will make the video/audio player invisible."
    },
    media_playlist_hide_active = {
        Value = false,
        Comment = "Enabling this will hide the current active video from being displayed inside the playlist."
    },
    media_playlist_auto_resize = {
        Value = true,
        Comment = "Disabling will disable the playlists rescaling functionality and make it static."
    },
    media_playlist_hide = {
        Value = false,
        Comment = "Enabling this will hide the playlist from the screen completely."
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
        Comment = "Inverts the x position of the playlist, you can use this to make things position from the right of the screen instead of the left."
    },
    media_player_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the player, you can use this to make things position from the right of the screen instead of the left."
    },
    media_settings_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the settings panel, you can use this to make things position from the right of the screen instead of the left."
    },
    media_vote_invert_position = {
        Value = false,
        Comment = "Inverts the x position of a vote, you can use this to make things position from the right of the screen instead of the left."
    },
    media_admin_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the admin panel, you can use this to make things position from the right of the screen instead of the left."
    },
    media_base_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the base panel, you can use this to make things position from the right of the screen instead of the left."
    },
    media_warning_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the warning box, you can use this to make things position from the right of the screen instead of the left."
    },
    media_success_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the success box, you can use this to make things position from the right of the screen instead of the left."
    },
    media_search_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the search panel, you can use this to make things position from the right of the screen instead of the left."
    },
    media_player_centered = {
        Value = false,
        Comment = "(unused)"
    },
    media_vote_centered = {
        Value = false,
        Comment = "(unused)"
    },
    preset_enable_server_default = {
        Value = true,
        Comment = "Disabling this will mean that your settings and in extension look are uneffected by joining servers which have an initial preset present."
    },
    media_playlist_show_constantly = {
        Value = false,
        Comment = "Enabling this will show the playlist in all areas of the ui (scoreboard, hud, context)."
    },
    media_player_show_current_video = {
        Value = true,
        Comment = "Diabling this will keep the player hidden even if a new video is playing. You would enable this if you were looking to stop the player reappearing, always keeping it hidden, except for instance in the scoreboard or context menu."
    },
    media_player_show_current_video_constantly = {
        Value = true,
        Comment = "Disabling this will mean that the player does not ignore other show settings when a video is active and function properly. You would disable this if you were looking to keep your player always hidden except for in the scoreboard or context menu."
    },
    media_settings_centered = {
        Value = false,
        Refresh = false,
        Comment = "The settings window will open centered to the middle of your screen."
    },
    media_admin_centered = {
        Value = false,
        Comment = "The admin window will open centered to the middle of your screen."
    },
    media_warning_centered = {
        Value = true,
        Comment = "The warning box will open centered to the middle of your screen."
    },
    media_success_centered = {
        Value = true,
        Comment = "The success box will open centered to the middle of your screen."
    },
    media_search_centered = {
        Value = true,
        Comment = "The search window will open centered to the middle of your screen."
    },
    media_player_show_in_context = {
        Value = false,
        Comment = "Enabling this will make the player visible in the context menu."
    },
    media_player_show_in_scoreboard = {
        Value = true,
        Comment = "Enabling this will make the player visible in the scoreboard menu."
    },
    media_playlist_show_in_context = {
        Value = false,
        Comment = "Enabling this will make the playlist visible in the context menu."
    },
    media_playlist_show_in_scoreboard = {
        Value = true,
        Comment = "Enabling this will make the playlist visible in the scoreboard menu."
    },
    media_player_hide = {
        Value = false,
        Comment = "Enabling this will disable the player from being visible."
    },
    media_player_show_constantly = {
        Value = false,
        Comment = "Enabling this show the player in all areas of the game (scoreboard, hud, context)."
    },
    media_search_hide = {
        Value = true,
        Comment = "(unused)"
    },
    media_settings_hide = {
        Value = true,
        Comment = "Disabling this will mean the settings panel will constantly be visible, making the creation of presets easier."
    },
    media_playlist_display_limit = {
        Value = 10,
        Min = 2,
        Max = 40,
        Refresh = false,
        Convar = false,
        Comment = "How many videos to display inside the playlist, will add a panel after this amount with the total videos currently on the playlist."
    },
    media_vote_hide = {
        Value = false,
        Comment = "Will disable votes from appearing."
    },
    media_admin_hide = {
        Value = true,
        Comment = "(unused)"
    },
    media_base_hide = {
        Value = false,
        Comment = "(unused)"
    },
    all_show = {
        Value = false,
        Comment = "Enabling this will show all UI elements used by Easy Mediaplayer (recommended for preset creation)"
    },
    media_player_mute = {
        Value = false,
        Comment = "Enabling this will mute the audio completely."
    },
    media_player_volume = {
        Value = 100,
        Min = 0,
        Max = 100,
        Comment = "Sets the volume of the player."
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
        Min = 15,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 750,
            Padding = 15
        },
        Refresh = false,
        SlowUpdate = 1,
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
            Padding = 5,
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
            Padding = 5,
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
            Border = MediaPlayer.Colours.FadedBlack,
            SecondaryBorder = MediaPlayer.Colours.FadedBlack,
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
    media_base_options = {
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
            Border = MediaPlayer.Colours.FadedBlack,
            SecondaryBorder = MediaPlayer.Colours.FadedBlack,
            LoadingBarBackground = MediaPlayer.Colours.Red
        }
    },
    media_player_size = {
        Min = 1,
        Max = 1000,
        Value = {
            Width = 500,
            Height = 300,
            Padding = 2,
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
