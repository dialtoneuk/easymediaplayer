
--types of videos
LydsPlayer.MediaType = LydsPlayer.MediaType or {
	YOUTUBE = "youtube",
	YOUTUBE_MUSIC = "youtube_music",
	MP3 = "mp3",
	DAILYMOTION = "dailymotion",
	SOUNDCLOUD = "soundcloud"
}

--[[
	Shared Hooks
	---------------------------------------------------------------------------
--]]

--This is executed after the gamemode is loaded and loads our settings from file for both the client and server
hook.Add("PostGamemodeLoaded", "LydsPlayer.LoadSettings", function()
	LydsPlayer.LoadSettings() --Load our settings from file
	LydsPlayer.SetConvars() --Set convar values to match the settings values just loaded by convar

	hook.Call("LydsPlayer.SettingsPostLoad") --Call post load hook
end)

--This is what we should do when we should down
hook.Add("ShutDown", "LydsPlayer.Shutdown", function()
	LydsPlayer.SaveSettings() --Save our settings

	if (SERVER) then
		LydsPlayer.SaveSession() --Save our history file
		LydsPlayer.SaveBlacklist() --Save our black list
		LydsPlayer.SaveJoinlist() --Save our join list
	end
end)
