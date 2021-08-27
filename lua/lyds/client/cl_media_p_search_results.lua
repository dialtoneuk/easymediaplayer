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
			Height = true,
		},
		Declare = {
			Type = MediaPlayer.MediaType.YOUTUBE,
			LastValue = ""
		}
	})

	self.ScrollPanel = vgui.Create("DScrollPanel", self)
	self.SearchBox = vgui.Create("DTextEntry", self )
	self.ComboBox = vgui.Create( "DComboBox", self.SearchBox )
	self.SearchButton = vgui.Create( "DButton", self.SearchBox )
	self.ColumnWidth = self.Settings.ColumnWidth.Value

	self:SetUpGrid()

	self.ScrollPanel:Dock(FILL)
	self:SetDockMargin(self.ScrollPanel, 2)

	self:SetDockMargin(self.SearchBox, 2 )
	self.SearchBox:SetTall(40)
	self.SearchBox:Dock(TOP)
	self.SearchBox:SetPlaceholderText("Press enter to search this media platform for content")

	self.SearchBox.OnEnter = function()
		if (self.SearchBox:GetValue() != "" and self.LastValue != self.SearchBox:GetValue() ) then
			RunConsoleCommand("media_search", self.ComboBox:GetValue(), self.SearchBox:GetValue() )
			self.LastValue =  self.SearchBox:GetValue()
			self.SearchBox:SetDisabled(true)
			self.SearchButton:SetDisabled(true)

			timer.Simple(1, function()
				if (!IsValid(self.SearchBox)) then return end
				self.SearchBox:SetDisabled(false)
			end)
		end
	end

	self.SearchBox.OnChange = function()
		self.SearchButton:SetDisabled(false)

		if (self.SearchBox:GetValue() == "") then
			self.SearchButton:SetDisabled(true)
		end
	end

	self.SearchButton:SetTall(30)
	self.SearchButton:Dock(RIGHT)
	self.SearchButton:SetText("Search")
	self.SearchButton:SetWidth(100)
	self.SearchButton:SetIcon("icon16/world.png")
	self.SearchButton:SetDisabled(true)
	self.SearchButton.DoClick = self.SearchBox.OnEnter

	self:RebuildComboBox()
end

function panel:RebuildComboBox()

	if (IsValid(self.ComboBox)) then self.ComboBox:Remove() end

	self.ComboBox = vgui.Create("DComboBox", self.SearchBox)
	self.ComboBox:SetTall(30)
	self.ComboBox:SetWide(self:GetWidth() / 6)
	self.ComboBox:Dock(RIGHT)
	self.ComboBox:SetValue( next(MediaPlayer.EnabledMediaTypes) )

	for k,v in pairs(MediaPlayer.EnabledMediaTypes) do
		self.ComboBox:AddChoice(k)
	end
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
	self:SetUpGrid()
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

	pan.DoClick = function()

		if (!table.IsEmpty(MediaPlayer.CurrentVideo) and result.Video == MediaPlayer.CurrentVideo.Video ) then
			MediaPlayer.CreateWarningBox("Video alreay present","Video is currently playing")
			return
		end

		if (!table.IsEmpty(MediaPlayer.Playlist) and  MediaPlayer.Playlist[result.Video] != nil ) then
			MediaPlayer.CreateWarningBox("Video alreay present","Video already in playlist!")
			return
		end

		self.Parent:ShowVideoInfo(result)
	end

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


	local html = vgui.Create("DHTML", pan)
	html:Dock(RIGHT)
	html:SetSize( self.Settings.Size.Value.RowHeight, self.Settings.Size.Value.RowHeight)
	html:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. ( result.Thumbnail or "" ) .. "></img>")
	html:SetMouseInputEnabled(false)

	return pan
end

--Register
vgui.Register("MediaPlayer.SearchResults", panel, "MediaPlayer.BasePanel")