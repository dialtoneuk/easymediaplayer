--[[
Admin Panel
------------------------------------------------------------------------------
--]]


local panel = {}

--settings
panel.Name = "admin"

--init
function panel:Init()
	self:BaseInit({
		--equiv to self.Selected = {}
		Declare = {
			Selected = {}
		}
	})

	if (!MediaPlayer.LocalPlayer:IsAdmin()) then self:Remove() return end

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:Dock(FILL)

	self:CreateBlacklistPanel()
	self.PropertySheet:AddSheet("Blacklist", self.BContainer, "icon16/cross.png")
end

function panel:Paint()
	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
end

--[[

--]]

function panel:MyThink()
	if (self:HasRescaled()) then
		self.List:SetWide(self:GetWide() - 40)
		self.List:SetTall(self:GetTall() - (self:GetTall() / 4))
	end
end

--[[

--]]

function panel:CreateBlacklistPanel()

	if (self.BContainer and IsValid(self.BContainer)) then self.BContainer:Remove() end

	self.BContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.BContainer:Dock(FILL)
	self.BContainer:DockMargin(15,15,15,15)

	self.List = vgui.Create("DListView", self.BContainer)
	self.List:SetTall(self:GetTall() - 95)
	self.List:SetWide(self:GetWide() - 40)
	self.List:Dock(TOP)
	self.List:SetMultiSelect(false)
	self.List:AddColumn( "Title" )
	self.List:AddColumn( "Date Added" )
	self.List:AddColumn( "Submitted By" )
	self.List:AddColumn( "Added by" )
	self.List:AddColumn( "Video" )

	self.SelectedPanel = vgui.Create("DPanel", self.BContainer)
	self.SelectedPanel:SetTall( 30 )
	self.SelectedPanel:SetWide(self:GetWide() - 40)
	self.SelectedPanel:Dock(BOTTOM)
	self.SelectedPanel:DockPadding(5,5,5,5)
	self.SelectedPanel:Hide()

	if ( self.Settings.Colours != nil) then
		self.SelectedPanel.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ButtonBackground )
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.ButtonBorder)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end

	local button = vgui.Create("DButton", self.SelectedPanel )
	button:Dock(BOTTOM)
	button:SetTall(20)
	button:SetText("Remove")
	button:SetImage("icon16/cross.png")
	button.DoClick = function()
		if (!self.Selected or table.IsEmpty(self.Selected)) then return end

		RunConsoleCommand("media_unblacklist_video", self.Selected.Video )
		MediaPlayer.Blacklist[self.Selected.Video] = nil

		if (table.IsEmpty(MediaPlayer.Blacklist)) then self.List:Clear() end

		self.Selected = {}
		self.SelectedPanel:SetDisabled(true)
	end

	self.List.OnRowSelected = function( lst, index, pnl )
		self.Selected = MediaPlayer.Blacklist[pnl:GetColumnText(5)]
		self.SelectedPanel:Show()
		self.SelectedPanel:SetDisabled(false)
	end

	local rbutton = vgui.Create("DButton", self.BContainer )
	rbutton:Dock(BOTTOM)
	rbutton:SetTall(20)
	rbutton:DockMargin(5,5,5,5)
	rbutton:SetText("Refresh")
	rbutton:SetImage("icon16/tick.png")
	rbutton.DoClick = function()
		RunConsoleCommand("media_reload_blacklist")
	end

	if (MediaPlayer.Blacklist and !table.IsEmpty(MediaPlayer.Blacklist)) then
		self:PresentBlacklist()
	end
end

--[[

--]]

function panel:PresentBlacklist()

	if (!MediaPlayer.LocalPlayer:IsAdmin()) then self:Remove() return end

	self.List:Clear()

	for k,v in pairs( MediaPlayer.Blacklist ) do
		self.List:AddLine(v.Title, os.date( "%H:%M:%S - %d/%m/%Y",v.DateAdded), v.Owner.Name, v.Admin.Name, v.Video )
	end
end

--Register panel
vgui.Register("MediaPlayer.AdminPanel", panel, "MediaPlayer.Base")
