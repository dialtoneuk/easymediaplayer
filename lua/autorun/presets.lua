--you can auto generate this in console lua_run_cl MediaPlayer.PrintDefaultPresets() on client and following print instructions
--make sure sv_cheats 1
--NOTE: this has to be done manually due to gmod writing limitations as well as addon creation limitations

if (SERVER) then return end --isnt loaded on server

--autogenerated 2021-8-27 07-06-08

MediaPlayerPresets = {
	['kawaii.json'] = [[{"Description":"User created preset","Author":"Lyds","Locked":true,"Settings":{"warning_auto_resize":false,"settings_options":{"BorderThickness":2.0,"DisplayTitle":false},"base_invert_position":false,"success_options":{"BorderThickness":2.0,"DisplayTitle":true},"base_size":{"Padding":5.0,"RowHeight":40.0,"Width":750.0,"Height":500.0},"player_size":{"Padding":2.0,"LoadingBarHeight":6.0,"Width":500.0,"Height":60.0},"success_auto_resize":false,"settings_resize_scale":0.75,"vote_position":{"Y":83.49431818181819,"X":10.0},"admin_invert_position":false,"warning_size":{"Padding":5.0,"Width":750.0,"Height":500.0},"success_resize_scale":1.0,"search_options":{"BorderThickness":2.0,"DisplayTitle":false},"playlist_resize_scale":1.0,"player_position":{"Y":10.0,"X":10.0},"search_resize_scale":0.3,"vote_options":{"BorderThickness":2.0,"DisplayTitle":true},"vote_auto_resize":false,"vote_size":{"Padding":15.0,"LoadingBarHeight":5.0,"Width":190.0,"Height":75.0},"admin_options":{"BorderThickness":2.0,"DisplayTitle":true},"admin_auto_resize":false,"vote_invert_position":false,"player_colours":{"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"SecondaryBorder":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":255.0,"b":193.0,"a":255.0,"g":127.0},"LoadingBarBackground":{"r":104.0,"b":255.0,"a":255.0,"g":139.0}},"admin_size":{"Width":500.0,"Height":500.0},"playlist_invert_position":true,"base_auto_resize":false,"success_colours":{"Border":{"r":76.0,"b":136.0,"a":255.0,"g":255.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":0.0,"b":0.0,"a":147.0,"g":0.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"playlist_options":{"BorderThickness":2.0,"DisplayTitle":true},"warning_colours":{"Border":{"r":255.0,"b":12.0,"a":200.0,"g":0.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":0.0,"b":0.0,"a":181.0,"g":0.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"player_auto_resize":false,"playlist_colours":{"ItemActiveBackground":{"r":255.0,"b":193.0,"a":255.0,"g":127.0},"SecondaryBorder":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBackground":{"r":120.0,"b":251.0,"a":255.0,"g":183.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":59.0,"b":59.0,"a":255.0,"g":59.0},"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"ItemBorder":{"r":255.0,"b":223.0,"a":200.0,"g":223.0}},"search_invert_position":false,"search_auto_resize":true,"base_colours":{"Border":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"admin_position":{"Y":25.0,"X":25.0},"vote_resize_scale":1.0,"player_options":{"BorderThickness":2.0,"DisplayTitle":true},"player_resize_scale":1.0,"search_position":{"Y":25.0,"X":25.0},"player_invert_position":false,"search_size":{"Padding":5.0,"RowHeight":120.0,"Width":800.0,"Height":800.0},"warning_invert_position":false,"base_options":{"BorderThickness":2.0,"DisplayTitle":true},"playlist_size":{"Padding":4.0,"RowSpacing":2.0,"Width":499.0,"RowHeight":65.0,"Height":60.0},"settings_invert_position":false,"base_resize_scale":1.0,"search_colours":{"HeaderBorder":{"r":255.0,"b":193.0,"a":255.0,"g":127.0},"HeaderBackground":{"r":150.0,"b":255.0,"a":255.0,"g":192.0},"ItemBackground":{"r":255.0,"b":214.0,"a":255.0,"g":127.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":255.0,"b":171.0,"a":255.0,"g":127.0},"ItemBorder":{"r":255.0,"b":253.0,"a":255.0,"g":236.0},"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0}},"admin_resize_scale":0.75,"base_position":{"Y":25.0,"X":25.0},"settings_colours":{"Border":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"SecondaryBorder":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":255.0,"b":171.0,"a":255.0,"g":127.0}},"warning_resize_scale":1.0,"warning_options":{"BorderThickness":2.0,"DisplayTitle":true},"success_position":{"Y":25.0,"X":25.0},"success_invert_position":false,"admin_colours":{"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"ButtonBorder":{"r":255.0,"b":110.0,"a":255.0,"g":0.0},"TextColor":{"r":10.0,"b":10.0,"a":255.0,"g":10.0},"Background":{"r":255.0,"b":171.0,"a":255.0,"g":127.0},"ButtonBackground":{"r":1.0,"b":1.0,"a":200.0,"g":1.0}},"playlist_position":{"Y":10.0,"X":5.0},"success_size":{"Padding":5.0,"Width":400.0,"Height":400.0},"warning_position":{"Y":25.0,"X":25.0},"settings_position":{"Y":25.0,"X":25.0},"settings_size":{"Padding":5.0,"RowHeight":30.0,"Width":800.0,"Height":715.0},"playlist_auto_resize":true,"settings_auto_resize":false,"vote_colours":{"Border":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":255.0,"b":171.0,"a":255.0,"g":127.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"LoadingBarBackground":{"r":255.0,"b":206.0,"a":255.0,"g":103.0}}}}]],
	['default.json'] = [[{"Author":"Lyds","Settings":{"warning_auto_resize":false,"settings_options":{"BorderThickness":1.0,"DisplayTitle":false},"vote_position":{"Y":420.0,"X":10.0},"warning_size":{"Padding":5.0,"Width":750.0,"Height":500.0},"success_resize_scale":1.0,"playlist_resize_scale":1.0,"player_position":{"Y":10.0,"X":10.0},"vote_options":{"BorderThickness":5.159090909090909,"DisplayTitle":true},"vote_auto_resize":false,"playlist_position":{"Y":10.0,"X":10.0},"admin_auto_resize":false,"search_column_count":3.0,"search_options":{"BorderThickness":1.0,"DisplayTitle":true},"admin_size":{"Width":500.0,"Height":500.0},"vote_invert_position":false,"base_auto_resize":false,"playlist_options":{"BorderThickness":2.0,"DisplayTitle":true},"base_size":{"Padding":5.0,"Width":750.0,"Height":500.0,"RowHeight":40.0},"vote_resize_scale":1.0,"search_size":{"Padding":5.0,"Width":750.0,"Height":500.0,"RowHeight":120.0},"base_options":{"BorderThickness":2.0,"DisplayTitle":true},"warning_invert_position":false,"base_resize_scale":1.0,"admin_colours":{"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"ButtonBorder":{"r":255.0,"b":0.0,"a":135.0,"g":0.0},"TextColor":{"r":10.0,"b":10.0,"a":255.0,"g":10.0},"Background":{"r":180.0,"b":180.0,"a":255.0,"g":180.0},"ButtonBackground":{"r":255.0,"b":0.0,"a":200.0,"g":0.0}},"success_size":{"Padding":5.0,"Width":400.0,"Height":400.0},"settings_position":{"Y":25.0,"X":25.0},"base_invert_position":false,"success_options":{"BorderThickness":2.0,"DisplayTitle":true},"player_size":{"Padding":2.0,"Width":500.0,"Height":300.0,"LoadingBarHeight":5.0},"admin_invert_position":false,"search_resize_scale":0.4971590909090909,"success_auto_resize":false,"player_auto_resize":true,"admin_options":{"BorderThickness":2.0,"DisplayTitle":true},"player_colours":{"Border":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"SecondaryBorder":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":127.0,"b":0.0,"a":130.0,"g":21.0},"LoadingBarBackground":{"r":255.0,"b":0.0,"a":255.0,"g":0.0}},"playlist_invert_position":true,"success_colours":{"Border":{"r":0.0,"b":76.0,"a":200.0,"g":255.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"search_invert_position":false,"search_auto_resize":true,"base_colours":{"Border":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"playlist_colours":{"ItemActiveBackground":{"r":4.0,"b":1.0,"a":255.0,"g":0.0},"SecondaryBorder":{"r":127.0,"b":0.0,"a":255.0,"g":0.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":127.0,"b":44.0,"a":134.0,"g":0.0},"Border":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"ItemBorder":{"r":10.0,"b":10.0,"a":200.0,"g":10.0}},"player_options":{"BorderThickness":2.0,"DisplayTitle":true},"player_resize_scale":1.0,"search_position":{"Y":25.0,"X":25.0},"player_invert_position":false,"playlist_size":{"Padding":3.0,"RowSpacing":3.0,"Width":400.0,"RowHeight":75.0,"Height":100.0},"settings_invert_position":false,"settings_size":{"Padding":5.0,"Width":800.0,"Height":715.0,"RowHeight":60.0},"vote_size":{"Padding":15.0,"Width":190.0,"Height":75.0,"LoadingBarHeight":5.0},"admin_resize_scale":0.75,"base_position":{"Y":25.0,"X":25.0},"settings_colours":{"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":125.0,"b":124.0,"a":157.0,"g":123.0},"SecondaryBorder":{"r":37.0,"b":37.0,"a":255.0,"g":37.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0}},"settings_resize_scale":0.75,"warning_options":{"BorderThickness":2.0,"DisplayTitle":true},"success_position":{"Y":25.0,"X":25.0},"gui_resize_scale":3.0,"settings_auto_resize":false,"search_colours":{"HeaderBorder":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"HeaderBackground":{"r":163.0,"b":163.0,"a":255.0,"g":163.0},"ItemBackground":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":179.0,"b":179.0,"a":255.0,"g":179.0},"ItemBorder":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"Border":{"r":255.0,"b":255.0,"a":255.0,"g":255.0}},"warning_colours":{"Border":{"r":255.0,"b":0.0,"a":200.0,"g":0.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"warning_position":{"Y":25.0,"X":25.0},"admin_position":{"Y":25.0,"X":25.0},"vote_colours":{"Border":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"Background":{"r":127.0,"b":0.0,"a":126.0,"g":0.0},"LoadingBarBackground":{"r":255.0,"b":0.0,"a":255.0,"g":0.0},"TextColor":{"r":10.0,"b":10.0,"a":255.0,"g":10.0}},"playlist_auto_resize":true,"warning_resize_scale":1.0,"success_invert_position":false},"Locked":true,"Description":"User created preset"}]],
	['darky.json'] = [[{"Settings":{"vote_colours":{"Border":{"r":97.0,"b":97.0,"a":255.0,"g":97.0},"Background":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"LoadingBarBackground":{"r":255.0,"b":0.0,"a":255.0,"g":216.0},"TextColor":{"r":10.0,"b":10.0,"a":255.0,"g":10.0}},"warning_auto_resize":false,"settings_options":{"BorderThickness":1.0,"DisplayTitle":false},"base_invert_position":false,"success_options":{"BorderThickness":2.0,"DisplayTitle":true},"warning_colours":{"Border":{"r":255.0,"b":0.0,"a":200.0,"g":0.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"player_size":{"Padding":2.0,"Height":300.0,"LoadingBarHeight":5.0,"Width":500.0},"admin_options":{"BorderThickness":2.0,"DisplayTitle":true},"search_options":{"BorderThickness":1.0,"DisplayTitle":false},"vote_position":{"Y":10.0,"X":520.0},"admin_invert_position":false,"warning_size":{"Padding":5.0,"Width":750.0,"Height":500.0},"success_resize_scale":1.0,"settings_size":{"Padding":5.0,"Height":715.0,"RowHeight":60.0,"Width":800.0},"playlist_resize_scale":1.0,"settings_resize_scale":0.75,"search_resize_scale":0.3,"success_auto_resize":false,"warning_position":{"Y":25.0,"X":25.0},"vote_size":{"Padding":15.0,"Height":75.0,"LoadingBarHeight":5.0,"Width":190.0},"playlist_position":{"Y":10.0,"X":10.0},"admin_auto_resize":false,"vote_invert_position":false,"player_colours":{"Border":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"SecondaryBorder":{"r":107.0,"b":107.0,"a":200.0,"g":107.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"LoadingBarBackground":{"r":72.0,"b":255.0,"a":255.0,"g":0.0}},"admin_size":{"Width":500.0,"Height":500.0},"playlist_invert_position":true,"success_colours":{"Border":{"r":0.0,"b":76.0,"a":200.0,"g":255.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"vote_options":{"BorderThickness":2.0,"DisplayTitle":true},"playlist_options":{"BorderThickness":2.0,"DisplayTitle":true},"base_auto_resize":false,"vote_resize_scale":1.0,"search_invert_position":false,"base_size":{"Padding":5.0,"Height":500.0,"RowHeight":40.0,"Width":750.0},"search_auto_resize":true,"base_colours":{"Border":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBackground":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBorder":{"r":0.0,"b":255.0,"a":200.0,"g":0.0}},"admin_position":{"Y":25.0,"X":25.0},"playlist_colours":{"ItemActiveBackground":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"SecondaryBorder":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"ItemBackground":{"r":52.0,"b":52.0,"a":255.0,"g":52.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0},"Background":{"r":135.0,"b":135.0,"a":255.0,"g":135.0},"Border":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"ItemBorder":{"r":20.0,"b":2.0,"a":200.0,"g":2.0}},"player_options":{"BorderThickness":1.3409090909090909,"DisplayTitle":true},"player_resize_scale":0.9,"search_position":{"Y":25.0,"X":25.0},"player_invert_position":false,"search_size":{"Padding":5.0,"Height":500.0,"RowHeight":120.0,"Width":750.0},"base_position":{"Y":25.0,"X":25.0},"base_options":{"BorderThickness":2.0,"DisplayTitle":true},"playlist_size":{"Padding":5.0,"RowSpacing":1.0,"Width":500.0,"RowHeight":60.59943181818182,"Height":90.0},"settings_invert_position":false,"base_resize_scale":1.0,"warning_resize_scale":1.0,"admin_resize_scale":0.75,"search_colours":{"HeaderBorder":{"r":0.0,"b":0.0,"a":255.0,"g":0.0},"HeaderBackground":{"r":163.0,"b":163.0,"a":255.0,"g":163.0},"ItemBackground":{"r":59.0,"b":59.0,"a":255.0,"g":59.0},"TextColor":{"r":255.0,"b":255.0,"a":200.0,"g":255.0},"Background":{"r":59.0,"b":59.0,"a":255.0,"g":59.0},"ItemBorder":{"r":172.0,"b":172.0,"a":255.0,"g":172.0},"Border":{"r":0.0,"b":0.0,"a":255.0,"g":0.0}},"settings_colours":{"Border":{"r":0.0,"b":0.0,"a":200.0,"g":0.0},"SecondaryBorder":{"r":163.0,"b":255.0,"a":255.0,"g":127.0},"Background":{"r":10.0,"b":10.0,"a":200.0,"g":10.0},"TextColor":{"r":255.0,"b":255.0,"a":255.0,"g":255.0}},"warning_invert_position":false,"warning_options":{"BorderThickness":2.0,"DisplayTitle":true},"success_position":{"Y":25.0,"X":25.0},"player_position":{"Y":10.0,"X":10.0},"admin_colours":{"Border":{"r":255.0,"b":149.0,"a":255.0,"g":127.0},"ButtonBorder":{"r":140.0,"b":255.0,"a":255.0,"g":0.0},"TextColor":{"r":10.0,"b":10.0,"a":255.0,"g":10.0},"Background":{"r":0.0,"b":0.0,"a":163.0,"g":0.0},"ButtonBackground":{"r":1.0,"b":1.0,"a":200.0,"g":1.0}},"player_auto_resize":true,"success_size":{"Padding":5.0,"Width":400.0,"Height":400.0},"gui_resize_scale":3.0,"settings_position":{"Y":25.0,"X":25.0},"vote_auto_resize":false,"playlist_auto_resize":true,"settings_auto_resize":false,"success_invert_position":false},"Description":"User created preset","Locked":true,"Author":"Lyds"}]],
}