--[[
	Easy MediaPlayer Player

	see autorun folder for where global table is defined + error capturing
--]]

--types of videos
MediaPlayer.MediaType = MediaPlayer.MediaType or {
	YOUTUBE = "youtube",
	YOUTUBE_MUSIC = "youtube_music",
	MP3 = "mp3",
	DAILYMOTION = "dailymotion",
	SOUNDCLOUD = "soundcloud"
}


--[[
	Hooks
	---------------------------------------------------------------------------
--]]

--[[
 	Start Up
--]]

hook.Add("PostGamemodeLoaded", "MediaPlayer.LoadSettings", function()
	MediaPlayer.LoadSettings()
	MediaPlayer.SetConvars()

	--Client and server called
	hook.Call("MediaPlayer.SettingsPostLoad")
end)
--[[
	Shutdown
--]]

hook.Add("ShutDown", "MediaPlayer.SaveSettingsShutdown", function()
	MediaPlayer.SaveSettings()

	if (SERVER) then
		MediaPlayer.SaveHistory()
		MediaPlayer.SaveBlacklist()
		MediaPlayer.SaveJoinlist()
	end
end)
