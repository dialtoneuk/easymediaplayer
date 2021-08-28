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

	self:AddSearchPanel()
	self:AddSessionPanel()
	self:AddHistoryPanel()
end

function panel:AddHistoryPanel()
	self.SearchHistoryContainer = vgui.Create("MediaPlayer.SearchHistoryContainer", self.PropertySheet )
	self.SearchHistoryContainer.ColumnWidth = ( self:GetWidth() / self:GetSettingInt("ColumnCount") ) - 15
	self.SearchHistoryContainer:Dock(FILL)
	self.SearchHistoryContainer:AddDefaultPanel()

	self.PropertySheet:AddSheet("History", self.SearchHistoryContainer, "icon16/zoom.png")
end

function panel:AddSessionPanel()
	self.SearchSessionContainer = vgui.Create("MediaPlayer.SearchSessionContainer", self.PropertySheet )
	self.SearchSessionContainer.ColumnWidth = ( self:GetWidth() / self:GetSettingInt("ColumnCount") ) - 15
	self.SearchSessionContainer:Dock(FILL)

	self.PropertySheet:AddSheet("Session", self.SearchSessionContainer, "icon16/hourglass.png")
end

function panel:AddSearchPanel()
	self.SearchContainer = vgui.Create("MediaPlayer.SearchContainer", self.PropertySheet )
	self.SearchContainer.ColumnWidth = ( self:GetWidth() / self:GetSettingInt("ColumnCount") ) - 15
	self.SearchContainer:Dock(FILL)
	self.SearchContainer:AddDefaultPanel()

	self.SearchController = vgui.Create("DPanel", self.SearchContainer )
	self.SearchController:Dock(BOTTOM)
	self.SearchController:SetTall( self:GetWidth() / 6 )
	self.SearchController:Hide()
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

	self.SearchItem:Dock(FILL)
	self.SearchItem:SetVideo(video)

	self.SearchController:Show()
end

function panel:ShowResults(typ, tab)
	self.SearchContainer:SetType(typ)

	if (table.IsEmpty(tab)) then
		self.SearchContainer:ClearGrid()
		self.SearchContainer:AddDefaultPanel()
	else
		self.SearchContainer:SetResults(tab)
	end
end

vgui.Register("MediaPlayer.SearchPanel", panel, "MediaPlayer.Base")
