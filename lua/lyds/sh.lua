
--types of videos
MediaPlayer.MediaType = MediaPlayer.MediaType or {
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
hook.Add("PostGamemodeLoaded", "MediaPlayer.LoadSettings", function()
	MediaPlayer.LoadSettings() --Load our settings from file
	MediaPlayer.SetConvars() --Set convar values to match the settings values just loaded by convar

	hook.Call("MediaPlayer.SettingsPostLoad") --Call post load hook
end)

--This is what we should do when we should down
hook.Add("ShutDown", "MediaPlayer.Shutdown", function()
	MediaPlayer.SaveSettings() --Save our settings

	if (SERVER) then
		MediaPlayer.SaveSession() --Save our history file
		MediaPlayer.SaveBlacklist() --Save our black list
		MediaPlayer.SaveJoinlist() --Save our join list
	end
end)
