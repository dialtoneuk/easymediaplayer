# Easy MediaPlayer for Garrysmod

Written by Llydia Cross.

## What is this

Easy MediaPlayer is a media addon which allows a garrysmod server (or just your self!) to watch and listen to media together via a server wide playlist. It supports several sites, such as Soundcloud, Dailymotion and Youtube as well as Youtube Music.

Featured is an easy to use settings panel which allows the easy editing of a fully customizable UI system which powers all of the visual elements. It comes with a preset system which can be used to save and switch the 100+ configuration options included. Admins are also able to set default presets which will be applied to any new players which join your server, allowing for the plugin to seamlessly integrate with your communities aesthetic.

Users of this plugin are advised to read each of comments provided for the settings to fully get an understanding of what each of them do. Your client settings are seperated from the servers settings and will follow you through each server which uses Easy MediaPlayer, so you don't have to worry about your styling being messed up.

**NOTE:** If you take the time to create your own look with Easy MediaPlayer then you must save it as a preset and change the setting `media_allow_initial_settings` to false overweise it will be overwritten when you join a server (for the first time) and the server has Easy MediaPlayer installed. If you forget to flick the setting, you can always revert back to your saved preset.

# Hooks

Easy MediaPlayer comes with some hooks for easy customisability by developers. More will be gradually added with each update.

## Shared Hooks


```
MediaPlayer.SettingsLoaded
```

Called once the lua file for the settings controller has been parsed, is always the first thing to be called. Use this hook to add your own functions which invoke `MediaPlayer.RegisterSettings(server: table, client: table)`

```
MediaPlayer.SettingsPostLoad
```

Called after all settings have been registered and any saved persistant settings in the data have replaced the default registered values. If you are using the settings system and want to ensure that things run once the settings load, use this hook.

## Server Hooks


```
MediaPlayer.PreloadRegisteredVotes
```

Called before votes are registered. Use this hook to add custom votes by invoking the method `MediaPlayer.AddRegisteredVotes(tab: table)`, see sv_media_voting.lua for an example of how the parameter table must be structured!

```
MediaPlayer.PreloadRegisteredCooldowns
```

Called after the default cooldowns have been loaded, use this hook to add your own custom cooldowns (between actions). You can create new cooldowns by invoking `MediaPlayer.StoreCooldown(cooldown: table)`, see sv_media_cooldown.lua for an example

```
MediaPlayer.PreloadRegisteredCommands
```

Called before chat commands have been registered. Use this hook to add custom votes by invoking the method `MediaPlayer.AddRegisteredCommands(tab: table)`, see sv_media_chatcommands.lua for an example of how the parameter table must be structured!