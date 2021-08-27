
local server = {
	announce_admin = {
		Value = true,
		Comment = "Announce to the server when an admin skips or removes videos from the playlist."
	},
	announce_video = {
		Value = true,
		Comment = "Announce to the server when a new video has begun."
	},
	announce_addition = {
		Value = true,
		Comment = "Announce to the server when a new video has been added to the playlist."
	},
	announce_ending = {
		Value = true,
		Comment = "Announce to the server when a video has come to its end."
	},
	announce_spawn = {
		Value = true,
		Comment = "Announce to the player that the server is running this plugin."
	},
	announce_count = {
		Value = true,
		Comment = "Announce to the server when a vote has gained a new vote."
	},
	announce_vote = {
		Value = true,
		Comment = "Announce the creation of new votes to the server."
	},
	announce_likes = {
		Value = true,
		Comment = "Announce to the server when a player has liked a video."
	},
	announce_dislikes = {
		Value = true,
		Comment = "Announce to the server when a player has disliked a video."
	},
	announce_settings = {
		Value = true,
		Comment = "Announce to all admins online when edits to the servers settings are made."
	},
	tips_enabled = {
		Value = true,
		Comment = "Tips will be posted into the chats of players."
	},
	tips_frequency = {
		Value = 600, --every 10 mins
		Max = 1000,
		Comment = "In seconds, how frequent tips will be posted into the chats of players."
	},
	media_history_max = {
		Value = 10,
		Max = 50,
		Comment = "The amount of items to return to the player when they request the servers history inside the search panel."
	},
	cooldown_enabled = {
		Value = true,
		Dangerous = true,
		Comment = "Users will recieve cooldowns (it is recommended that you keep this enabled)"
	},
	cooldown_play = {
		Value = 45,
		Max = 500,
		Comment = "How many seconds the player has to wait once submitting a video."
	},
	cooldown_vote = {
		Value = 10,
		Max = 500,
		Comment = "How many seconds the player has to wait once starting a vote.",
	},
	cooldown_search = {
		Value = 30,
		Max = 120,
		Comment = "How many seconds the player has to wait after searching for media. (its recommended you keep this at its current value).",
	},
	cooldown_interaction = {
		Value = 180,
		Max = 500,
		Comment = "How many seconds the player has to wait after liking or disliking a video. (players can only like/dislike the current video a single time anyway).",
	},
	cooldown_history = {
		Value = 1,
		Max = 500,
		Comment = "How many seconds the player has to wait after requesting server history. (its recommended you keep this at its current value).",
	},
	cooldown_refreshrate = {
		Value = 1,
		Max = 6,
		Comment = "Setting this to a value of two will effectively double the time all cooldowns take, setting it to three will tripple and so forth. Use this to change the server to slowmode temporarily."
	},
	cooldown_command = {
		Value = 1,
		Max = 600,
		Comment = "How many seconds the player has to wait between using chat commmands."
	},
	chatcommand_prefix = {
		Value = "!",
		Dangerous = true,
		Comment = "This is the prefix which Easy Mediaplayer will attach to its chat commands. Change this to another character if it conflicts with one of your other addons."
	},
	video_max_duration = {
		Value = 1200,
		Max = 60000,
		Comment = "Roughly in seconds how long a piece of media can be no matter the platform."
	},
	video_ban_after_dislikes = {
		Value = 50,
		Max = 500,
		Min = 0,
		Comment = "After a piece of media has been disliked over the ammount defined it will be added automatically to the ban list. You can set this to zero if you wish not to ban videos based on dislikes."
	},
	tips_custom = {
		Value = {
			"this is a tip",
			"so is this"
		},
		Comment = "(editing coming soon)",
		Max = 20, --max elements
		Custom = true
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
		Value = true,
		Comment = "Enables youtube as being a supported media type."
	},
	youtube_music_enabled = {
		Value = false,
		Comment = "Enables youtube as being a supported media type."
	},
	youtube_api_key = {
		Value = "REPLACE WITH YOUR OWN",
		Comment = "Head over to google dashboard and create API credientials which have access to the Youtube Data API (version 3)"
	},
	dailymotion_enabled = {
		Value = false,
		Comment = "Enables dailymotion as being a supported media type."
	},
	dailymotion_api_key = {
		Value = "REPLACE WITH YOUR OWN",
		Comment = "TODO: Fill"
	},
	soundcloud_enabled = {
		Value = false,
		Comment = "Enables soundcloud as being a supported media type."
	},
	soundcloud_api_key = {
		Value = "REPLACE WITH YOUR OWN",
		Comment = "(unimplemented as soundcloud has closed its doors to its API)"
	},
	mp3_enabled = {
		Value = false,
		Comment = "Enables mp3 submissions. (please read the readme.md)."
	},
	mp3_https_only = {
		Value = true,
		Comment = "Only allows https links to be submitted."
	},
}

--client settings

local client = {

	media_blocked_videos = {
		Value = {
			Video_1 = "DRfidJNts6U"
		},
		Custom = true,
		Comment = "(editing coming soon)"
	},
	gui_resize_scale = {
		Value = 4,
		Max = 10,
		Refresh = true,
		SlowUpdate = 2,
		Comment = "Changing this to a lower value will increase the size of every element. Decreasing this number will decrease the size of every element."
	},
	preset_allow_initial = {
		Icon = "icon16/layout_add.png",
		Value = true,
		Comment = "Disabling this will mean that your settings are never overwritten by a server preset."
	},
	all_show = {
		Icon = "icon16/find.png",
		Value = false,
		Refresh = true,
		Comment = "Enabling this will show all UI elements used by Easy Mediaplayer (recommended for preset creation)"
	},
	chat_colours = {
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
hook.Add("MediaPlayer.SettingsLoaded","MediaPlayer.RegisterLegacySettings", function()
	MediaPlayer.RegisterSettings(server, client)
end)
