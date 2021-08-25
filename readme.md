<p align="center">
  <img src=https://i.imgur.com/N8xsjHr.png" title="Easy Mediaplayer" alt="accessibility text">
</p>

<p align="center">
Written by Llydia Cross.
<p>

<small align="center" style='color: gray'>
   Copyright 2021 Llydia Cross

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
</small>

## What is this

Easy MediaPlayer is a media addon which allows a garrysmod server (or just your self!) to watch and listen to media together via a server wide playlist. It currently supports several sites, such as Dailymotion and Youtube as well as Youtube Music and also mp3s.

## Note:
As of 2021, the chromium web engine is not in the game by default due to some crashes and bugs that can occur. I myself have experienced several of these crashes, how ever I have found that crashes are actually more persitant on the "older html engine" than the newer one and _its really no bother switching to the x86-x64 and sticking wih it_. In regards to using this plugin on a server, <u>the only thing which will work on the older html engine are mp3 links which use a very primative javascript api to function, no videos will ever be possible now **flash is dead**</u>.

**NOTE:** I have noticed several game crashing bugs with this addon on branches other than the chromium branch. These are simply impossible for me to fix as they are due to the older html engine, so please don't submit bug reports if you aren't on the chromium branch.

### Direct MP3 Mode

The server does not
 * Download or directly access any of the mp3s submitted.
 * Actually check if an mp3 is a valid mp3 (that would require downloading it).
 * Verify with complete accuracy that an mp3 can be played.

What it will do is
 * Checks the link given by the user is indeed a valid mp3 and is accessible by the server (not 404) through a bog standard http get <u>(the return body of this request is the mp3 data or potentially bad data and does not leave the executory block of the http fetch function and is immediately marked for garbage collection)</u>
 * Check if a user is outright banned from posting mp3s (can help with abuse)
 * Put the mp3 into a container so even if its bad, it just won't play.

 Its really up to you if you decide to disable this feature or not. If you do change the setting `mp3_enabled` to false inside the server tab of the settings panel

## More Important Things To Notes

**NOTE:** Sever operators which use this plugin are advised to read each of comments provided for the settings to fully get an understanding of what each of them do. As for users, your client settings are seperated from the servers settings and will follow you through each server which uses Easy MediaPlayer, so you don't have to worry about your styling being messed up.

**NOTE: <u>Always save your client settings as a preset!</u>** Or change the setting `preset_allow_default` to false overwise it will be overwritten when you join a server (for the first time) which has Easy Mediaplayer Installed and a server initial server. If you forget to flick the setting, you can always revert back to your saved preset. Remember to include any _centered or _inverted or _hide settings in the presets settings as they are not added implicitly when the default settings checkbox is true in the preset creator

# Features

* Server wide media playlist supporting Youtube, Youtube Music, Dailymotion, direct mp3s with more planned in the future!
* Extensive admin controls to easy moderate the media submitted.
* Voting system included for skipping and banning videos
* Fully customisable user inferface with over 100 options. (See below)
* Extremely comprehensive client and server settings editor allowing for full customizability of all parts of the addon inside of garrymosd its self. Please check out the wiki for more information on what each setting does.
* Preset system for all client settings with the ability for admins to set a **default preset to apply to all new players who join that server, allowing Easy MediaPlayer to look and feel different between all servers.** Also allows for quick switching between themes, this addon comes with several included by default.
* Comes packed with lots of ways to find the media you want to play. From using the built in UI or through chat commands (See Below)
* Comes packed with lots of predefined chat commands, such as !vote and !voteskip. (Your severs command prefix can be changed in the settings panel)
* Server-based historical records are kept of the videos being played, by who and when. (Does not use SQL and is purely json based)
* Video engagements such as likes and dislikes.
* Pointshop Integration
* Developer hooks and open source code, built for expanding upon (and heavily encouraged)
* Stable and migrates perfectly with newer versions, making it safe you to keep getting updates from the Steam Workshop.

# Hooks Overview

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

Called after the default cooldowns have been loaded, use this hook to add your own custom cooldowns (between actions). You can create new cooldowns by invoking `MediaPlayer.StoreCooldown(cooldown: table)`, see sv_cooldown.lua for an example

```
MediaPlayer.PreloadRegisteredCommands
```

Called before chat commands have been registered. Use this hook to add custom votes by invoking the method `MediaPlayer.AddRegisteredCommands(tab: table)`, see sv_media_chatcommands.lua for an example of how the parameter table must be structured!

# More Information

Coming soon is a detailed wiki, once I've fully finished developing internal functionality. Until then, please just get in touch with me through my discord if you have any developer specific questions. <u>I will not offer any forms of support for free but I'm very happy to answer questions on how to do stuff.</u>

Discord `llydia#2476`

# Donations

Please feel free to purchase my music, you'll get to show your appreciation and also get something back for it. Cheers!

https://llydia.bandcamp.com/