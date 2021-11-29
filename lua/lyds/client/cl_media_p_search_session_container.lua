local panel = {}

panel.Name = "search"

panel.Settings = {
	PageLimit = "page_limit",
	ColumnCount = "column_count",
	ColumnWidth = "column_width",
}

function panel:Init()
	self:BaseInit({
		DontResize = {
			Width = true,
			Height = true
		},
		Declare = {
			Results = {},
		}
	})

	self.ScrollPanel = vgui.Create("DScrollPanel", self)
	self.FetchButton = vgui.Create( "DButton", self.ScrollPanel )
	self.ColumnWidth = self.Settings.ColumnWidth.Value

	self.ScrollPanel:Dock(FILL)
	self:SetDockMargin(self.ScrollPanel, 2)

	self.FetchButton:SetTall(30)
	self.FetchButton:Dock(TOP)
	self.FetchButton:SetText("Refresh Session")
	self.FetchButton:SetIcon("icon16/world.png")
	self.FetchButton:SetDisabled(true)
	self.FetchButton.DoClick = function()

	end

	self:SetUpGrid()
end

function panel:SetUpGrid()

	if (IsValid(self.Grid)) then self.Grid:Remove() end

	self.Grid = vgui.Create("DGrid", self.ScrollPanel )
	self:SetDockMargin(self.Grid)

	self.Grid:SetCols( self:GetSettingInt("ColumnCount") )
	self.Grid:SetTall(self:GetHeight())
	self.Grid:SetColWide( self.ColumnWidth )
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() * 2 )
end

vgui.Register("LydsPlayer.SearchSessionContainer", panel, "LydsPlayer.BasePanel")