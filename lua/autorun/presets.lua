--you can auto generate this in console lua_run_cl MediaPlayer.PrintDefaultPresets() on client and saving the output to this file
--make sure sv_cheats 1
--NOTE: has to be done manually due to gmod writing limitations

if (SERVER) then return end

MediaPlayerPresets = {
	['default.json'] = [[{
		"Settings": {
			"media_settings_size": {
				"Width": 500,
				"Height": 500,
				"Padding": 50
			}
		},
		"Locked": true,
		"Description": "The default look and feel",
		"Author": "Llydia"
	}]],

	['test.json'] = [[{
		"Settings": {
			"media_settings_size": {
				"Width": 500,
				"Height": 500,
				"Padding": 50
			}
		},
		"Locked": true,
		"Description": "The default look and feel",
		"Author": "Llydia"
	}]],
}
