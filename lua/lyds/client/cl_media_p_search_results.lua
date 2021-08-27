local panel = {}

panel.Name = "search"

panel.Settings = {
	PageLimit = "page_limit"
}

function panel:Init()

	self:BaseInit({
		DontRescale = {
			Width = true,
			Height = true,
		},
		Declare = {
			Type = MediaPlayer.MediaType.YOUTUBE
		}
	})

	self.ScrollPanel = vgui.Create("DScrollPanel", self)
	self.Grid = vgui.Create("DGrid", self.ScrollPanel )
	self.SearchBox = vgui.Create("DEntryBox", self.ScrollPanel )
	self.ColumnWidth = ( self:GetWidth() / 3 ) - self:GetPadding() * 3

	self.ScrollPanel:Dock(FILL)

	self.Grid:DockMargin(0, self:GetPadding() * 4, 0, 0)
	self.Grid:SetCols( 3 )
	self.Grid:SetTall(self:GetHeight())
	self.Grid:SetColWide( self.ColumnWidth )
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() * 2 )

	self.SearchBox.OnEnter = function()
		if (self.SearchBox:GetValue() != "") then
			RunConsoleCommand("media_youtube_search", self.SearchBox:GetValue() )
		end

		self.SearchBox:SetDisabled(true)
		timer.Simple(1, function()
			if (!IsValid(self.SearchBox)) then return end
			self.SearchBox:SetDisabled(false)
		end)
	end
end

function panel:SetUpGrid()
	self.Grid:SetCols( 3 )
	self.Grid:SetColWide( self.ColumnWidth )
	self.Grid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() * 2 )
end

function panel:SetType(typ)
	self.Type = type
end

function panel:SetResults(results)
	self:ClearGrid()

	local limit = table.Copy(self.Settings.PageLimit).Value

	for k,v in pairs(results) do
		if (limit == 0 ) then break end

		self.Grid:AddItem(self:ResultPanel(v))
		limit = limit - 1
	end
end

function panel:ClearGrid()
	for k,v in pairs(self.Grid:GetItems()) do
		self.Grid:RemoveItem(v, false)
	end
end

function panel:ResultPanel(result)
	local pan = vgui.Create("DButton", self.Grid )
	pan:SetWide( self.ColumnWidth - self:GetPadding() )
	pan:SetHeight(self.Settings.Size.Value.RowHeight)
	pan:SetText("")

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
	end

	local html = vgui.Create("DHTML", pan)
	html:Dock(RIGHT)
	html:SetSize( self.Settings.Size.Value.RowHeight * 2, self.Settings.Size.Value.RowHeight)
	html:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. ( result.Thumbnail or "" ) .. "></img>")

	local text = vgui.Create("DLabel", pan )
	text:SetWide(self:GetWidth(true, true))
	text:SetPos(5, 5)
	text:SetText(result.Title)
	text:SetFont("BigText")
	text:SetTextColor(self.Settings.Colours.Value.TextColor)

	local text2 = vgui.Create("DLabel", pan )
	text2:SetWide(self:GetWidth(true, true))
	text2:SetPos(5, 20)
	text2:SetText(result.Creator)
	text2:SetFont("MediumText")
	text2:SetTextColor(self.Settings.Colours.Value.TextColor)

	return pan
end

--Register
vgui.Register("MediaPlayer.SearchResults", panel, "MediaPlayer.BasePanel")