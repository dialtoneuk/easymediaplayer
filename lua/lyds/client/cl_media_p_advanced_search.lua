local panel = {}

panel.Name = "search"

panel.Settings = {
	AutoResize = "auto_resize",
	ColumnCount = "column_count",
	ColumnWidth = "column_width"
}


function panel:Init()
	self:BaseInit({
		DontResize = {
			Width = true,
			Height = true,
		}
	})

	if (!self:IsSettingTrue("AutoResize")) then
		self:SetIgnoreRescaling(false, false)
		self:Rescale()
	else
		self:RescaleTo(self:GetSettingInt("ResizeScale"))
	end

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:Dock(FILL)

	self.SearchContainer = vgui.Create("MediaPlayer.SearchResults", self.PropertySheet )
	self.SearchContainer.ColumnWidth = ( self:GetWidth() / self:GetSettingInt("ColumnCount") )
	self.SearchContainer.Parent = self
	self.SearchContainer:Dock(FILL)
	self.SearchContainer:SetZPos(0)


	self.SearchController = vgui.Create("DPanel", self.SearchContainer )
	self.SearchController:Dock(BOTTOM)
	self.SearchController:SetTall( self:GetWidth() / 6 )
	self.SearchController:Hide()
	self.SearchController:SetZPos(1)
	self.SearchController.Paint = function()
		return
	end

	self:SetDockMargin(self.SearchController)

	self.PropertySheet:AddSheet("Search", self.SearchContainer, "icon16/wand.png")
end

function panel:RebuildComboBox()
	self.SearchContainer:RebuildComboBox()
end

function panel:ShowVideoInfo(video)


	if (IsValid(self.SearchItem)) then
		self.SearchItem:SetVideo(video)
		self.SearchController:Show()
		return
	end

	self.SearchItem = vgui.Create("MediaPlayer.SearchItem", self.SearchController)
	self.SearchItem.Parent = self
	self.SearchItem:Dock(FILL)
	self.SearchItem:SetVideo(video)

	self.SearchController:Show()
end

function panel:ShowResults(typ, tab)
	self.SearchContainer:SetType(typ)
	self.SearchContainer:SetResults(tab)
end

vgui.Register("MediaPlayer.SearchPanel", panel, "MediaPlayer.Base")
