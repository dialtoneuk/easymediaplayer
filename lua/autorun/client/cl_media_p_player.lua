/*
	Player Panel
	----------------------------------------------------------------------------
*/


local panel = {}
panel.Name = "player"
panel.Video = {}

--Extra Settings
panel.Settings = {
	DisplayVideo = MEDIA.GetSetting("media_display_video")
}

--Our initial setup

function panel:Init()

	self:BaseInit()

	self.HTML = vgui.Create("DHTML", self)
	self.HTML:Dock(FILL)
	self.HTML:SetAllowLua(true)
	self.HTML:SetHTML("<marquee style='text-align: center; color: white; font-family: sans-serif; font-size: 15vw; padding-top: 10.99%;'>No Video</marquee>")
	--sets the volume of the player
	self.SetPlayerVolume = function(this)
		this = this or self.Wang
		self.HTML:QueueJavascript([[
		try{
			player.setVolume(" ]] .. this:GetValue() .. [[");
		} catch(e) {
			console.log("player is undefined or no video is playing");
		}
		]])
	end


	self.Wang = vgui.Create("DNumberWang", self)
	self.Wang:SetSize(45, 26)
	self.Wang:SetMin(0)
	self.Wang:SetMax(100)
	self.Wang:SetMin(0)
	self.Wang:SetMax(100)
	self.Wang:SetValue(100)
	self.Wang.OnValueChanged = self.SetPlayerVolume

	self.Paint = function()
		if (self.Settings.Colours != nil) then
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end

		if (!table.IsEmpty(MEDIA.CurrentVideo)) then
			draw.SimpleTextOutlined(self.Video.Title or "", "SmallText", 10, self:GetTall() - 30, MEDIA.Colours.White, 10, 1, 0.5, MEDIA.Colours.Black)
			draw.SimpleTextOutlined(self.Video.Creator or "", "MediumText", 10, self:GetTall() - 45, MEDIA.Colours.White, 10, 1, 0.5, MEDIA.Colours.Black)

			if (IsValid(self.Video.Owner) and self.Video.Owner != nil ) then
				draw.SimpleTextOutlined("Submitted by " .. self.Video.Owner:GetName() or "Unknown", "MediumText", 10, self:GetTall() - 15, MEDIA.Colours.White, 10, 1, 0.5,
				MEDIA.Colours.Black)
			end

			if (!table.IsEmpty(self.Video) and self.Video.StartTime) then
				local time = CurTime() - self.Video.StartTime
				local mins = math.Truncate(time / 60)
				local seconds = math.floor(time - (mins * 60))

				if (seconds < 10) then
					seconds = "0" .. seconds
				end

				local str = mins .. ":" .. seconds
				local w = surface.GetTextSize(str)

				draw.SimpleTextOutlined(str, "MediumText", self:GetWide() - w - 10, self:GetTall() - 45, MEDIA.Colours.White, 10, 1, 0.5, MEDIA.Colours.Black)
				surface.SetDrawColor(self.Settings.Colours.Value.LoadingBarBackground)
				surface.DrawRect(0, 0, math.Clamp((self:GetWide() / self.Video.Duration ) * time, 5, self:GetWide()), 5)
			end
		end
	end
end

--Normally use MyThink instead of Think
function panel:MyThink()
	if (self.Settings.DisplayVideo.Value == 0 and self.HTML:IsVisible()) then
		self.HTML:Hide()
	elseif (self.Settings.DisplayVideo.Value == 1 and !self.HTML:IsVisible()) then
		self.HTML:Show()
	end

	--eh
	self.Wang:SetPos(self:GetWide() - (self.Wang:GetWide() + 5), self:GetTall() - (self.Wang:GetTall() + 5))
end

--Sets the video HTML effectively playing it
function panel:SetVideo(video)
	if (table.IsEmpty(video)) then
		self.HTML:SetHTML("<marquee style='text-align: center; color: white; font-family: sans-serif; font-size: 15vw; padding-top: 10.99%;'>No Video</marquee>")
		return
	end

	self.Video = video
	self.HTML:SetHTML("<p style='text-align: center; color: white; font-family: sans-serif; font-size: 15vw;'>LOADING OwO</p>")
	local time = math.floor(1 + CurTime() - video.StartTime)
	--local link = "https://www.youtube.com/embed/" .. video.Video .. "?rel=0&enablejsapi=1&autoplay=1&controls=0&nohtml5=1&showinfo=0&loop=1&iv_load_policy=3&start=" .. time
	local mute = 0

	if (MEDIA.GetSetting("media_mute_video").Value == 1) then
		mute = 1
	end

	--self.HTML:SetHTML("<iframe style='width: 99%; height: 80%; border: 1px solid black;' src='" .. link .. "' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'></iframe>")
	self.HTML:SetHTML(self:GetHTMLSourceCode(video, time, mute))

	--replace this is dumb
	timer.Simple(1, function()
		self.SetPlayerVolume()
	end)
end

/*

*/

function panel:GetHTMLSourceCode(video, start_time, mute)
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
				margin-top: 15px;
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
vgui.Register("MEDIA_Player", panel, "MEDIA_BasePanel")