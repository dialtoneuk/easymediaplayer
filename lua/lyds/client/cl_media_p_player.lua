--player panel
local panel = {}

panel.Name = "player"

--Extra Settings
panel.Settings = {
	DisplayVideo = "display_video",
	Muted = "mute",
	ShowConstant =  "show_constantly"
}

--Our initial setup

function panel:Init()
	self:BaseInit({
		Declare = {
			Video = {}
		}
	})

	self.HTML = vgui.Create("DHTML", self)
	self.HTML:Dock(FILL)
	self.HTML:SetAllowLua(true)
	self:SetDefaultHTML()

	self.Wang = vgui.Create("DNumberWang", self)
	self.Wang:SetSize(45, 26)
	self.Wang:SetMin(0)
	self.Wang:SetMax(100)
	self.Wang:SetMin(0)
	self.Wang:SetMax(100)
	self.Wang:SetValue(100)
end

function panel:Paint()

	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWidth(), self:GetHeight())
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWidth(), self:GetHeight(), self.Settings.Options.Value.BorderThickness)
	surface.SetDrawColor(self.Settings.Colours.Value.SecondaryBorder)
	surface.DrawOutlinedRect(2, 2, self:GetWidth() - 4, self:GetHeight() - 4, self.Settings.Options.Value.BorderThickness)

	--todo: Optimise this
	if (!table.IsEmpty(LydsPlayer.CurrentVideo)) then

		local time = CurTime() - self.Video.StartTime
		local str = self:GetMinsSeconds(time)
		local total = self:GetMinsSeconds(self.Video.Duration)

		local w = surface.GetTextSize(str) or 1

		local tw = surface.GetTextSize("/" .. total)

		surface.SetDrawColor(self.Settings.Colours.Value.LoadingBarBackground)
		surface.DrawRect(0, 0, math.Clamp((self:GetWidth() / self.Video.Duration ) * time, 5, self:GetWidth()), self.Settings.Size.Value.LoadingBarHeight)

		local title = self.Video.Title

		if (self.Settings.Muted.Value) then
			title = title .. " (AUDIO MUTED!)"
		end

		draw.SimpleText(title, "PlaylistText", 10, self:GetHeight() - 40, self.Settings.Colours.Value.TextColor, 10)
		draw.SimpleText(self.Video.Creator .. " | " .. ( self.Video.Views or 0 ) .. " Views", "SmallText", 10, self:GetHeight() - 55,  self.Settings.Colours.Value.TextColor, 10)
		draw.SimpleText("Submitted by " .. self._CurrentVideoOwner, "SmallText", 10, self:GetHeight() - 22, self.Settings.Colours.Value.TextColor, 10)
		draw.SimpleText(str, "MediumText", ( self:GetWidth() - w - tw - 10) - self:GetPadding() * 4, self:GetHeight() - 55, self.Settings.Colours.Value.TextColor, 10)
		draw.SimpleText(" / " .. total, "MediumText", ( self:GetWidth() - tw - 10) - self:GetPadding() * 4, self:GetHeight() - 55, self.Settings.Colours.Value.TextColor, 10)
	end
end

function panel:SetYoutubeWang()
	--sets the volume of the player
	self.SetYoutubeVolume = function(this)
		this = this or self.Wang
		self.HTML:QueueJavascript([[
		try{
			player.setVolume(" ]] .. this:GetValue() .. [[");
		} catch(e) {
			console.log("player is undefined or no video is playing");
		}
		]])
	end

	self.Wang.OnValueChanged = self.SetYoutubeVolume
end

function panel:SetDefaultHTML()

	if (!IsValid(self.HTML)) then return end

	--TODO: turn this into a method
	self.HTML:SetHTML([[
		<div style='font-family: sans-serif; text-align: center; overflow: hidden'>
			<marquee style='text-align: center; color: white; font-size: 30vw; padding-top: 10.99%;'>No Video</marquee>
			<h1 style='margin-top: 15vh; font-size: 0vh; color: white'>PLEASE SWITCH TO THE CHROMIUM BRANCH ELSE YOU MIGHT CRASH</h1>
		</div>
	]])

end

function panel:GetMinsSeconds(time)
	time = time or CurTime()
	local mins = math.Truncate(time / 60)
	local seconds = math.floor(time - (mins * 60))

	if (seconds < 10) then
		seconds = "0" .. seconds
	end

	return mins .. ":" .. seconds
end

--Normally use MyThink instead of Think
function panel:MyThink()

	if (!self:InScoreboardMenu()) then
		self:MoveToBack()
	else
		self:MoveToFront()
	end

	if (self:HasRescaled()) then
		self:SetDockPadding()
	end

	if (!self:IsSettingTrue("DisplayVideo")) then
		self.HTML:Hide()
	else
		self.HTML:Show()
	end

	if (!table.IsEmpty(self.Video) and self._CurrentVideoOwner == nil and IsValid(self.Video.Owner)) then
		self._CurrentVideoOwner = self.Video.Owner:GetName()
	end

	--eh
	self.Wang:SetPos(self:GetWidth(true, true ) - (self.Wang:GetWide() + self:GetPadding() * 2), self:GetHeight(true, true ) - (self.Wang:GetTall() + self:GetPadding() * 2))
end

--Sets the video HTML effectively playing it
function panel:SetVideo(video)
	if (table.IsEmpty(video)) then
		self._CurrentVideoOwner = nil
		self.HTML:SetHTML([[
			<div style='font-family: sans-serif; text-align: center; overflow: hidden'>
				<marquee style='text-align: center; color: white; font-size: 30vw; padding-top: 10.99%;'>No Video</marquee>
				<h1 style='margin-top: 15vh; font-size: 0vh; color: white'>PLEASE SWITCH TO THE CHROMIUM BRANCH ELSE YOU MIGHT CRASH</h1>
			</div>
		]])

		if ( !self:IsSettingTrue("ShowConstant")) then
			self:Hide()
		end

		return
	end

	self.Video = video
	self.HTML:SetHTML("<p style='text-align: center; color: white; font-family: sans-serif; font-size: 15vw;'>LOADING OwO</p>")
	local time = math.floor(1 + CurTime() - video.StartTime)
	--local link = "https://www.youtube.com/embed/" .. video.Video .. "?rel=0&enablejsapi=1&autoplay=1&controls=0&nohtml5=1&showinfo=0&loop=1&iv_load_policy=3&start=" .. time
	local mute = 0

	if (self:IsSettingTrue("Muted")) then
		mute = 1
	end


	if (video.Type == LydsPlayer.MediaType.YOUTUBE) then

		self.HTML:SetHTML(self:GetYoutubeSourceCode(video, time, mute))
		self:SetYoutubeWang()

		--replace this is dumb needs to be done when browser loads
		timer.Simple(1, function()
			if (self.SetYoutubeVolume) then
				self.SetYoutubeVolume()
			end
		end)
	end
end

--[[

--]]

function panel:GetYoutubeSourceCode(video, start_time, mute)
	mute = mute or 0

	return [[
		<!DOCTYPE html>
		<html>
		<head>
			<style>
			body{
				margin: 0;
				padding: 0;
				-webkit-user-select: none;
				-moz-user-select: none;
				-ms-user-select: none;
				user-select: none;
			}

			#player{
				position: relative;
				margin-left: 10px;
				margin-top: 5px;
			}
			</style>
		</head>
		<body>
			<div id="player"></div>
		</body>
		<footer>
			<script>
				var tag = document.createElement('script');
				tag.src = "https://www.youtube.com/iframe_api";
				var firstScriptTag = document.getElementsByTagName('script')[0];
				firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

				var player;
				function onYouTubeIframeAPIReady() {
					player = new YT.Player('player', {
						height: ']] .. self:GetTall() - 75 .. [[',
						width: ']] .. self:GetWide() - 20 .. [[',
						videoId: ']] .. video.Video .. [[',
						playerVars: {
							playsinline: 1,
							start: ]] .. start_time .. [[,
							controls: 0,
							mute: ]] .. mute .. [[,
							nohtml5: 1
						},
						events: {
							onReady: onPlayerReady
						}
					});
				}

				function onPlayerReady(event) {
					event.target.playVideo();
				}
			</script>
		</footer>
		</html>
	]]
end

--Register
vgui.Register("LydsPlayer.PlayerPanel", panel, "LydsPlayer.BasePanel")