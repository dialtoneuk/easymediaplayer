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
			Page = 1,
			OrderBy = {
				"LastPlayed",
				"Likes",
				"Dislikes",
				"Plays"
			}
		}
	})

	self.ScrollPanel = vgui.Create("DScrollPanel", self)
	self.SearchButton = vgui.Create( "DButton", self.ScrollPanel )
	self.ColumnWidth = self.Settings.ColumnWidth.Value

	self.ScrollPanel:Dock(FILL)
	self:SetDockMargin(self.ScrollPanel, 2)

	local w = ( self:GetWidth() / 3 ) + self:GetPadding() * 2

	self.SearchButton:SetTall(30)
	self.SearchButton:SetWidth(w)
	self.SearchButton:SetText("Get History")
	self.SearchButton:SetIcon("icon16/world.png")
	self.SearchButton:SetDisabled(false)
	self.SearchButton.DoClick = function()
		local only = "false"
		local asc = "false"

	 	if (self.OnlyPlayer:GetChecked() ) then
			only = "true"
		end

		if (self.Asc:GetChecked() )  then
			asc = "true"
		end

		RunConsoleCommand("media_history", self.ComboBox:GetValue(), only, asc)
	end

	local wc = self:GetWidth() / 5

	self.ComboBox = vgui.Create("DComboBox", self.ScrollPanel)
	self.ComboBox:SetTall(30)
	self.ComboBox:SetPos(w + self:GetPadding(), 0)
	self.ComboBox:SetWide(wc)
	self.ComboBox:SetValue(self.OrderBy[1])

	for k,v in pairs(self.OrderBy) do
		self.ComboBox:AddChoice(v)
	end


	self.OnlyPlayer = vgui.Create("DCheckBoxLabel", self.ScrollPanel )
	self.OnlyPlayer:SetPos(w + wc + ( self:GetPadding() * 2 ), self:GetPadding())
	self.OnlyPlayer:SetText("Show only your history")
	self.OnlyPlayer:SetValue( false )
	self.OnlyPlayer:SizeToContents()

	self.Asc = vgui.Create("DCheckBoxLabel", self.ScrollPanel )
	self.Asc:SetPos(self:GetWidth() - 250, self:GetPadding())
	self.Asc:SetText("Results will ascend (smallest to largest)")
	self.Asc:SetValue( false )
	self.Asc:SizeToContents()

	self:SetUpGrid()
end

function panel:AddDefaultPanel()
	if (!IsValid(self.Grid)) then return end

	--adds default pls search panel
	self.Grid:AddItem(self:DefaultPanel())
end

function panel:SetSearchResults(results)
	self.Results = results

	self:SetUpGrid()

	for k,v in pairs(results) do

		local p = vgui.Create("MediaPlayer.SearchItemHistory", self.Grid)
		p:SetWide(self.ColumnWidth)
		p:SetTall(self.Settings.Size.Value.SecondaryRowHeight)
		p:SetVideo(v, k)

		self.Grid:AddItem(p)
	end
end

function panel:DefaultPanel()
	local pan = vgui.Create("DButton", self.Grid )
	pan:SetWide( self.ColumnWidth - self:GetPadding() )
	pan:SetHeight(self.Settings.Size.Value.RowHeight)
	pan:SetText("")

	self:SetDockPadding(pan)

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
		surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
		surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
	end

	local title = vgui.Create("DLabel", pan )
	title:SetWide(self:GetWidth(true, true))
	title:Dock(TOP)
	title:SetTall(40)
	title:SetText("No History")
	title:SetFont("BiggerText")
	title:SetTextColor(self.Settings.Colours.Value.TextColor)
	self:SetDockMargin(title)


	local subtitle = vgui.Create("DLabel", pan )
	subtitle:SetWide(self:GetWidth(true, true))
	subtitle:Dock(BOTTOM)
	subtitle:DockMargin(self:GetPadding(), 0, 0, self:GetPadding())
	subtitle:SetText("You can order by Plays, Likes and more. Check that you are on a valid page.")
	subtitle:SetTall(self.Settings.Size.Value.RowHeight / 2)
	subtitle:SetWrap(true)
	subtitle:SetFont("BigText")
	subtitle:SetTextColor(self.Settings.Colours.Value.TextColor)

	return pan
end

function panel:SetUpGrid()

	if (IsValid(self.Grid)) then self.Grid:Remove() end

	self.Grid = vgui.Create("DGrid", self.ScrollPanel )
	self:SetDockMargin(self.Grid)

	self.Grid:SetCols( self:GetSettingInt("ColumnCount") )
	self.Grid:SetTall(self:GetHeight() - 30 + self:GetPadding() )
	self.Grid:SetPos(0, 30 + self:GetPadding() * 2)
	self.Grid:SetColWide( self.ColumnWidth )
	self.Grid:SetRowHeight( self.Settings.Size.Value.SecondaryRowHeight + self:GetPadding() * 2 )
end

vgui.Register("MediaPlayer.SearchHistoryContainer", panel, "MediaPlayer.BasePanel")