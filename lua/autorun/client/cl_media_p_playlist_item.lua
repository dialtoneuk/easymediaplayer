--[[
  Playlist Item
	---------------------------------------------------------------------------
--]]

local panel = {}
panel.Name = "playlist"
panel.RescaleHeight = false
panel._Reposition = false

--the video data
panel.Video = {}

--Settings
panel.Settings = {
	Options = "options"
}

panel.Invert = {
	X = true,
	Y = false
}

--[[
	Initializes
--]]

function panel:Init()
	self:BaseInit()

	self:DockPadding(10,10,0,5)
	self:SetText("")

	self.Text = vgui.Create("DLabel", self )
	self.Text:SetFont("PlaylistText")
	self.Text:Dock(TOP)
	self.Text:SetWrap(true)
	self.Text:SetWide(self:GetWidth())
	self.Text:SetTall(40)
	self.Text:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.Duration = vgui.Create("DLabel", self )
	self.Duration:Dock(RIGHT)
	self.Duration:SetWide(self:GetHeight() / 2)
	self.Duration:SetFont("BigText")
	self.Duration:DockMargin(0,0,self:GetPadding() * 2, self:GetPadding() * 2)
	self.Duration:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.TextOwner = vgui.Create("DLabel", self )
	self.TextOwner:Dock(TOP)
	self.TextOwner:SetWide(self:GetWidth())
	self.TextOwner:SetFont("MediumText")
	self.TextOwner:SetTextColor(self.Settings.Colours.Value.TextColor)
	self:SetDockPadding(self.TextOwner)

	if (self.Settings.Colours != nil) then
	  	self.Paint = function(p)

			if (self.Active) then
				surface.SetDrawColor(self.Settings.Colours.Value.ItemActiveBackground)
			else
				surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			end

			surface.DrawRect(0, 0, self.Settings.Size.Value.Width - (self.Settings.Size.Value.Padding * 2), self.Settings.Size.Value.RowHeight )
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, self.Settings.Size.Value.Width - (self.Settings.Size.Value.Padding * 2), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness )
	  	end
	end

	--init do click
	self.DoClick = function()
		--does this each time if there is history for this video but too bad!
		if ( MediaPlayer.History != nil and MediaPlayer.History[ self.Item.Video ] != nil ) then
			self.Item = table.Merge(self.Item,  MediaPlayer.History[ self.Item.Video  ])
		end

		local menu = DermaMenu(false, self)
		menu:SetDeleteSelf( true )

		if (MediaPlayer.LocalPlayer:IsAdmin()) then
			if (!self.Active) then
				if (self.Item.Owner.SteamID != MediaPlayer.LocalPlayer:SteamID()) then
					local del = menu:AddOption( "Delete Video", function()
						RunConsoleCommand("MediaPlayer_delete", self.Item.Video )
					end)

					del:SetIcon("icon16/delete.png")
				end

				local bdel = menu:AddOption( "Blackist & Delete Video", function()
					RunConsoleCommand("MediaPlayer_blacklist_video", self.Item.Video )
				end)

				bdel:SetIcon("icon16/cross.png")
			else
				local skip = menu:AddOption( "Skip Video", function()
					RunConsoleCommand("MediaPlayer_skip_video", self.Item.Video )
				end)

				skip:SetIcon("icon16/resultset_next.png")

				local bdel = menu:AddOption( "Blacklist & Skip Video", function()
					RunConsoleCommand("MediaPlayer_blacklist_video", self.Item.Video )
				end)

				bdel:SetIcon("icon16/cross.png")
			end
		end

		local like = menu:AddOption( "Like Video (" .. (self.Item.Likes or 0) .. " likes)", function()
			RunConsoleCommand("MediaPlayer_like_video", self.Item.Video )
		end)

		like:SetIcon("icon16/award_star_add.png")

		local dislike = menu:AddOption( "Dislike Video (" .. (self.Item.Dislikes or 0) .. " dislikes)", function()
			RunConsoleCommand("MediaPlayer_dislike_video", self.Item.Video )
		end)

		dislike:SetIcon("icon16/award_star_delete.png")

		if ( !self.Active and ( self.Item.Owner.SteamID == MediaPlayer.LocalPlayer:SteamID() ) ) then
			local remove = menu:AddOption( "Remove Video", function()
				RunConsoleCommand("MediaPlayer_remove", self.Item.Video )
			end)
			remove:SetIcon("icon16/bomb.png")
		end

		menu:Open()
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
	self.Item = video
end

--[[
	Sets the texts
--]]

function panel:SetItemText()
	local mins = math.floor( self.Item.Duration / 60 )
	local result = (self.Item.Duration - (mins * 60))

	if (result < 10) then
		result = "0" .. result
	end

	self.Text:SetText(self.Item.Title .. " by " .. self.Item.Creator )
	self.Duration:SetText( mins .. ":" .. string.Replace(result,"-", "") )

	local str = self.Item.Owner.Name

	if (!self.Active) then
		self.TextOwner:SetText("submitted by " .. str)
	else
		self.TextOwner:SetText("submitted by " .. str .. " (is playing)")
	end
end

--Register Item
vgui.Register("MediaPlayer.PlaylistItem", panel, "MediaPlayer.BaseButton")