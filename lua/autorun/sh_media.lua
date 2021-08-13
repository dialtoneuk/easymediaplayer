--[[
	Easy Media Player

	This was written by Llydia Cross and is a free to use addon for Garrys Mod (2021). Please feel free to use the code here anywhere you like, and build off of it
	how ever you like. Hopefully you learn something about programming as the current documentation avaiable for the game is pretty bad in my opinion. A lot of people
	are focused on the money side and I get that, which is why you very rarely see any sort of Open Source lua projects. I thank the current community of developers
	who make their code accessible to all and allow others to extend off of it. Please feel free to email me at llydia@zyon.io if you have any questions about
	this code. Thanks!
--]]


--[[
	Hooks
	---------------------------------------------------------------------------
--]]

--[[
 	Start Up
--]]

hook.Add("PostGamemodeLoaded", "MEDIA_LoadSettings", function()
	MEDIA.LoadSettings()
	MEDIA.SetConvars()

	--Client and server called
	hook.Call("MEDIA_SettingsPostLoad")
end)

--[[
	Shutdown
--]]

hook.Add("ShutDown", "MEDIA_SaveSettingsShutdown", function()
	MEDIA.SaveSettings()

	if (SERVER) then
		MEDIA.SaveHistory()
		MEDIA.SaveBlacklist()
	end
end)
