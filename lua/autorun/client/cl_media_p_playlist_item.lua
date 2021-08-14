--[[
  Playlist Item
	---------------------------------------------------------------------------
--]]

local panel = {}

--the video data
panel.Video = {}

--Settings (we normally don't do this if we extend the base, but this extends a DButton!)
panel.Settings = {
	Colours = MEDIA.GetSetting("media_playlist_colours"),
	Size = MEDIA.GetSetting("media_playlist_size")
}

--[[
	Initializes
--]]

function panel:Init()

	self:DockPadding(5,5,5,5)
	self:SetText("")

	self.Text = vgui.Create("DLabel", self )
	self.Text:SetFont("MediumText")
	self.Text:Dock(TOP)
	self.Text:SetWrap(true)
	self.Text:SetWide(self:GetSettingWidth())
	self.Text:SetTall(30)
	self.Text:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.TextOwner = vgui.Create("DLabel", self )
	self.TextOwner:Dock(TOP)
	self.TextOwner:SetWide(self:GetSettingWidth())
	self.TextOwner:DockPadding(5,5,5,5)
	self.TextOwner:SetTall(20)
	self.TextOwner:SetFont("MediumText")
	self.TextOwner:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Duration = vgui.Create("DLabel", self )
	self.Duration:Dock(RIGHT)
	self.Duration:SetWide(40)
	self.Duration:SetTall(15)
	self.Duration:SetFont("MediumText")
	self.Duration:SetTextColor(self.Settings.Colours.Value.TextColor)



	if (self.Settings.Colours != nil) then
	  	self.Paint = function()

			if (self.Active) then
				surface.SetDrawColor(self.Settings.Colours.Value.ItemActiveBackground)
			else
				surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			end

			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
	  	end
	end
end

function panel:GetPadding(neg)
	neg = neg or false
	local padding = self.Settings.Size.Value.Padding or 0

	if (neg) then
		padding = padding - (padding * 2)
	end

	return padding
end

function panel:GetSettingWidth(set_padding, neg)
	neg = neg or false
	return self.Settings.Size.Value.Width + self:GetPadding(neg)
end

function panel:GetSettingHeight(set_padding, neg)
	neg = neg or false
	return self.Settings.Size.Value.Height + self:GetPadding(neg)
end

--[[
 Updates Colours
--]]

function panel:Think()
	if (self.Settings.Colours != nil) then
		self.Settings.Colours = MEDIA.GetSetting("media_playlist_colours")
	end
end

--[[
	Sets if we are active or not
--]]
function panel:SetActive()
	self.Active = true
end

--[[
	Sets our video
--]]

function panel:SetVideo(video)
	self.Video = video
	self.DoClick = function()

		--does this each time if there is history for this video but too bad!
		if ( MEDIA.History != nil and MEDIA.History[ video.Video ] != nil ) then
			video = table.Merge(video,  MEDIA.History[ video.Video ])
		end

		local menu = DermaMenu(false, self )
		menu:SetDeleteSelf( true )
		if (MEDIA.LocalPlayer:IsAdmin()) then
			if (!self.Active) then
				if (video.Owner.SteamID != MEDIA.LocalPlayer:SteamID()) then
					local del = menu:AddOption( "Delete Video", function()
						RunConsoleCommand("media_delete", video.Video )
					end)

					del:SetIcon("icon16/delete.png")
				end

				local bdel = menu:AddOption( "Blackist & Delete Video", function()
					RunConsoleCommand("media_blacklist_video", video.Video )
				end)

				bdel:SetIcon("icon16/cross.png")
			else
				local skip = menu:AddOption( "Skip Video", function()
					RunConsoleCommand("media_skip_video", video.Video )
				end)

				skip:SetIcon("icon16/resultset_next.png")

				local bdel = menu:AddOption( "Blacklist & Skip Video", function()
					RunConsoleCommand("media_blacklist_video", video.Video )
				end)

				bdel:SetIcon("icon16/cross.png")
			end
		end

		local like = menu:AddOption( "Like Video (" .. (video.Likes or 0) .. " likes)", function()
			RunConsoleCommand("media_like_video", video.Video )
		end)

		like:SetIcon("icon16/award_star_add.png")

		local dislike = menu:AddOption( "Dislike Video (" .. (video.Dislikes or 0) .. " dislikes)", function()
			RunConsoleCommand("media_dislike_video", video.Video )
		end)

		dislike:SetIcon("icon16/award_star_delete.png")

		if ( !self.Active and ( video.Owner.SteamID == MEDIA.LocalPlayer:SteamID() ) ) then
			local remove = menu:AddOption( "Remove Video", function()
				RunConsoleCommand("media_remove", video.Video )
			end)
			remove:SetIcon("icon16/bomb.png")
		end

		menu:Open()
	end
end

--[[
	Sets the texts
--]]

function panel:SetItemText()
	local mins = math.floor( self.Video.Duration / 60 )
	local result = (self.Video.Duration - (mins * 60))

	if (result < 10) then
		result = "0" .. result
	end

	self.Text:SetText(self.Video.Title .. " by " .. self.Video.Creator )
	self.Duration:SetText( mins .. ":" .. string.Replace(result,"-", "") )

	local str = self.Video.Owner.Name

	if (!self.Active) then
		self.TextOwner:SetText("submitted by " .. str)
	else
		self.TextOwner:SetText("submitted by " .. str .. " (is playing)")
	end
end

--Register Item
vgui.Register("MEDIA.PlaylistItem", panel, "DButton")