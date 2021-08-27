--[[
Search Panel
------------------------------------------------------------------------------
--]]

local panel = {}

--settings
panel.Name = "search"

--[[
	TODO: Branch all this out into more custom vgui elements
--]]

--[[
Fills the property sheet with all our shit
--]]

function panel:Init()
	self:BaseInit({
		Declare = {
			HistoryPage = 1,
			BrowserHistory = {},
			PlayerHistoryPage = 1,
			BrowserPosition = 0
		}
	})

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:SetTall(self:GetHeight())
	self.PropertySheet:Dock(FILL)

	self.SearchContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.ServerHistoryContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.PlayerHistoryContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.BrowserContainer = vgui.Create("DScrollPanel", self.PropertySheet )

	self:CreateBrowserPanel()
	self:CreateSearchPanel()
	self:CreateHistoryPanel()
	self:CreatePlayerHistoryPanel()

	self.PropertySheet:AddSheet("Search", self.SearchContainer, "icon16/wand.png")
	self.PropertySheet:AddSheet("Basic Browser", self.BrowserContainer, "icon16/page_white_world.png")
	self.PropertySheet:AddSheet("Player History", self.PlayerHistoryContainer, "icon16/user.png")
	self.PropertySheet:AddSheet("Server History", self.ServerHistoryContainer, "icon16/shield.png")

	self.PropertySheet.OnActiveTabChanged = function(old, new)
		self.Browser:OpenURL("https://www.youtube.com")
	end
end

function panel:Paint(p)
	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
end

--[[
Updates the size of our elements basically
--]]

function panel:MyThink()

	self.Grid:SetWide(self:GetWidth())
	self.Grid:SetColWide(self:GetWidth())

	if (self:HasRescaled()) then
		--wide
		self.Browser:SetWide(self:GetWidth())

		if (IsValid(self.HistoryGrid)) then
			self.HistoryGrid:SetColWide(self:GetWidth())
			self.HistoryGrid:SetTall(self:GetHeight())
			self.HistoryGrid:SetRowHeight(self.Settings.Size.Value.RowHeight + self:GetPadding() )
		end

		if (IsValid(self.PlayerHistoryGrid)) then
			self.PlayerHistoryGrid:SetColWide(self:GetWidth())
			self.PlayerHistoryGrid:SetTall(self:GetHeight())
			self.PlayerHistoryGrid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() )
		end


		--tall
		self.Grid:SetTall(self:GetHeight())
		self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self:GetPadding() )
	end
end

--[[

	TODO: Rewrite this
--]]

function panel:CreateBrowserPanel()

	local search_func = function(this)
		local val = this:GetValue()

		if (val == "") then
			return
		end

		--check if its a youtube url
		local result = MediaPlayer.ParseYoutubeURL(val)
		local is_mp3 = MediaPlayer.ValidMediaUrl(val)

		--if it is, play it
		if (result != nil ) then
			RunConsoleCommand("media_play", MediaPlayer.MediaTypes.YOUTUBE,  result )
			self.Browser:OpenURL("https://www.youtube.com")
		elseif (is_mp3 ) then
			RunConsoleCommand("media_play", MediaPlayer.MediaTypes.MP3, is_mp3 )
			self.Browser:OpenURL("https://www.youtube.com")
		else
			--just open the link
			self.Browser:OpenURL( val )
		end
	end

	self.UrlBox = vgui.Create("DTextEntry", self.BrowserContainer)
	self.UrlBox:DockMargin(5,5,5,5)
	self.UrlBox:Dock(TOP)
	self.UrlBox:SetTall(30)
	self.UrlBox.OnEnter = search_func

	self.BackButton = vgui.Create("DButton", self.UrlBox)
	self.BackButton:DockMargin(5,2,2,2)
	self.BackButton:Dock(RIGHT)
	self.BackButton:SetTall(10)
	self.BackButton:SetText("BCK")
	self.BackButton:Hide()
	self.BackButton:SetImage("icon16/arrow_left.png")
	self.BackButton.DoClick = function(that)
		self.ForwardButton:Show()

		if (self.BrowserHistory[ self.BrowserPosition - 1 ] != nil ) then
			self.Browser:OpenURL(self.BrowserHistory[ self.BrowserPosition - 1 ])
			self.BrowserPosition = self.BrowserPosition - 1

			if (self.BrowserPosition <= 1 ) then
				self.BackButton:Hide()
			end
		end
	end


	self.ForwardButton = vgui.Create("DButton", self.UrlBox)
	self.ForwardButton:DockMargin(5,2,2,2)
	self.ForwardButton:Dock(RIGHT)
	self.ForwardButton:SetTall(10)
	self.ForwardButton:Hide()
	self.ForwardButton:SetText("FWD")
	self.ForwardButton:SetImage("icon16/arrow_right.png")
	self.ForwardButton.DoClick = function(that)
		if (self.BrowserHistory[ self.BrowserPosition + 1 ] != nil ) then
			self.Browser:OpenURL(self.BrowserHistory[ self.BrowserPosition + 1 ])
			self.BrowserPosition = self.BrowserPosition + 1

			if ( self.BrowserHistory[ self.BrowserPosition + 1 ] == nil  ) then
				that:Hide()
			end

			if (self.BrowserPosition >= 2 ) then
				self.BackButton:Show()
			end
		end
	end

	self.Browser = vgui.Create("DHTML", self.BrowserContainer )
	self.Browser:SetSize(self:GetWidth() - 25,  self:GetHeight() - 70)
	self.Browser:DockPadding(5,5,5,5)
	self.Browser:Dock(FILL)

	--alowLua in this browser
	self.Browser:SetAllowLua(true)

	--binds lua to JS
	self.Browser:AddFunction("console", "seturl", function(str)
		self.GrabButton:SetDisabled(true)

		if (!string.find(str, "https://")) then
			if (!string.find(str, "http://")) then
				return
			end

			str = string.Replace(str, "http://", "https://")
		end

		if ( self.BrowserPosition == 2 ) then
			self.BackButton:Show()
		end

		if (!table.HasValue(self.BrowserHistory, str)) then
			table.insert(self.BrowserHistory, #self.BrowserHistory + 1, str)
			self.BrowserPosition = #self.BrowserHistory
		end

		self.UrlBox:SetValue(str)
		self.GrabButton:SetDisabled(false)

		MediaPlayer.URL = str
	end)

	self.Browser.OnChangeTitle = function(this)
		this:QueueJavascript("console.seturl(document.location.href)")
	end

	self.GrabButton = vgui.Create("DButton", self.Browser)
	self.GrabButton:Dock(BOTTOM)
	self.GrabButton:SetWide(self:GetWidth() - 25)
	self.GrabButton:SetTall(30)
	self.GrabButton:SetImage("icon16/tick.png")
	self.GrabButton:SetText("Grab")
	self.GrabButton:SetDisabled(true)
	self.GrabButton.DoClick = function()

		if (MediaPlayer.URL == nil) then
			return
		end

		if (MediaPlayer.URL == "https://www.youtube.com" or MediaPlayer.URL == "http//www.youtube.com" ) then return end

		timer.Simple(2, function()
			self.GrabButton:SetDisabled(false)
		end)

		local result = MediaPlayer.ParseYoutubeURL(MediaPlayer.URL)

		if (result != nil ) then
			RunConsoleCommand("media_play", MediaPlayer.MediaType.YOUTUBE, result )
			self.Browser:OpenURL("https://www.youtube.com")
		end
	end
end

--[[
Creates the panel we search for videos with
--]]

function panel:CreateSearchPanel()

	self.Search = vgui.Create("DTextEntry", self.SearchContainer )
	self.Search:Dock(TOP)
	self.Search:SetPlaceholderText("Will search youtube.com for valid videos")
	self.Search:DockMargin(15,15,15,15)
	self.Search:SetWide(self:GetWidth())
	self.Search:SetTall(30)

	self.Search.OnEnter = function()
		if (self.Search:GetValue() != "") then
			RunConsoleCommand("media_youtube_search", self.Search:GetValue() )
		end

		self.Search:SetDisabled(true)
		timer.Simple(1, function()
			self.Search:SetDisabled(false)
		end)
	end

	self.SearchButton = vgui.Create("DButton", self.Search )
	self.SearchButton:SetText("Search")
	self.SearchButton:SetImage("icon16/world.png")
	self.SearchButton:Dock(RIGHT)
	self.SearchButton:SetWide(120)
	self.SearchButton.DoClick = function()
		if (self.Search:GetValue() != "") then
			RunConsoleCommand("media_youtube_search", self.Search:GetValue() )
		end

		self.Search:SetDisabled(true)
		self.SearchButton:SetDisabled(true)
		timer.Simple(1, function()
			self.Search:SetDisabled(false)
			self.SearchButton:SetDisabled(false)
		end)
	end

	self:RefreshSearchGrid()

	if (MediaPlayer.SearchResults and !table.IsEmpty(MediaPlayer.SearchResults)) then
		self:PresentSearchResults(false, MediaPlayer.MediaType.YOUTUBE)
	end
end

--[[
Presents our search results
--]]

function panel:PresentSearchResults(clear, typ)
	if (clear) then
		self:RefreshSearchGrid()
	end

	if (!MediaPlayer.SearchResults) then self:OnEmpty(self.Grid) return end
	if (table.IsEmpty(MediaPlayer.SearchResults)) then self:OnEmpty(self.Grid)  return end

	self.Grid:SetColWide(self:GetWidth())

	for k,v in pairs(MediaPlayer.SearchResults) do
		local pan = vgui.Create("DButton", self.Grid )
		pan:SetWide(self:GetWidth(true, true) - self:GetPadding() * 4 - 20)
		pan:SetHeight(self.Settings.Size.Value.RowHeight)
		pan:SetText("")

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, self:GetWidth(), self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, self:GetWidth(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", MediaPlayer.MediaType.YOUTUBE, v.Video )
		end

		local html = vgui.Create("DHTML", pan)
		html:Dock(RIGHT)
		html:SetSize( self.Settings.Size.Value.RowHeight * 2, self.Settings.Size.Value.RowHeight)
		html:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. v.Thumbnail .. "></img>")

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self:GetWidth(true, true))
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor)

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self:GetWidth(true, true))
		text2:SetPos(5, 20)
		text2:SetText(v.Creator)
		text2:SetFont("MediumText")
		text2:SetTextColor(self.Settings.Colours.Value.TextColor)

		self.Grid:AddItem(pan)
	end
end

--[[
Creates our server history panel
--]]

function panel:CreateHistoryPanel()
	self.FetchButton = vgui.Create("DButton", self.ServerHistoryContainer )
	self.FetchButton:SetText("Fetch")
	self.FetchButton:SetImage("icon16/world.png")
	self.FetchButton:Dock(TOP)
	self.FetchButton:SetTall(30)
	self.FetchButton:SetWide( self:GetWidth())
	self:SetDockMargin(self.FetchButton)

	self.FetchButton.DoClick = function()

		if (self.HistoryPage == 1 ) then
			self:RefreshHistoryGrid()
		end

		RunConsoleCommand("media_request_history", self.HistoryPage )
		self.FetchButton:SetDisabled(true)

		timer.Simple(1, function()
			self.FetchButton:SetDisabled(false)
			self.ResetButton:Show()
		end)
	end

	self.ResetButton = vgui.Create("DButton", self.ServerHistoryContainer )
	self.ResetButton:SetText("Reset")
	self.ResetButton:SetImage("icon16/cross.png")
	self.ResetButton:Dock(TOP)
	self.ResetButton:SetTall(30)
	self.ResetButton:Hide()
	self.ResetButton:SetWide( self:GetWidth())
	self:SetDockMargin(self.ResetButton)

	self.ResetButton.DoClick = function(this)
		self:RefreshHistoryGrid()
		self.HistoryPage = 1
		this:Hide()
	end

	self:RefreshHistoryGrid()

	if (MediaPlayer.History != nil and !table.IsEmpty(MediaPlayer.History)) then
		self:PresentHistory()
	end
end

--[[

--]]

function panel:CreatePlayerHistoryPanel()
	self.PlayerFetchButton = vgui.Create("DButton", self.PlayerHistoryContainer )
	self.PlayerFetchButton:SetText("Fetch")
	self.PlayerFetchButton:SetTall(30)
	self.PlayerFetchButton:SetImage("icon16/world.png")
	self.PlayerFetchButton:Dock(TOP)
	self.PlayerFetchButton:SetWide( self:GetWidth())
	self:SetDockMargin(self.PlayerFetchButton)

	self.PlayerFetchButton.DoClick = function()
		if (self.PlayerHistoryPage == 1 ) then
			self:RefreshPlayerGrid()
		end

		RunConsoleCommand("media_request_personal_history", self.PlayerHistoryPage )
		self.PlayerFetchButton:SetDisabled(true)

		timer.Simple(1, function()
			self.PlayerFetchButton:SetDisabled(false)
			self.PlayerResetButton:Show()
		end)
	end

	self.PlayerResetButton = vgui.Create("DButton", self.PlayerHistoryContainer )
	self.PlayerResetButton:SetText("Reset")
	self.PlayerResetButton:SetImage("icon16/cross.png")
	self.PlayerResetButton:Dock(TOP)
	self.PlayerResetButton:SetTall(30)
	self.PlayerResetButton:Hide()
	self.PlayerResetButton:SetWide( self:GetWidth())
	self:SetDockMargin(self.PlayerResetButton)

	self.PlayerResetButton.DoClick = function(this)
		self:RefreshPlayerGrid()
		self.PlayerHistoryPage = 1
		this:Hide()
	end

	self:RefreshPlayerGrid()

	if (MediaPlayer.PlayerHistory and !table.IsEmpty(MediaPlayer.PlayerHistory)) then
		self:PresentPlayerHistory()
	end
end

--[[
Presents history we get from the server
--]]

function panel:PresentHistory()
	for k,v in SortedPairsByMemberValue(MediaPlayer.History, "LastPlayed", true ) do

		if (string.sub(k,1,2) == "__") then continue end
		if ( v.Owner == nil ) then v.Owner = {} end

		local pan = vgui.Create("DButton", self.HistoryGrid )
		pan:SetWide( ( self:GetWidth(true, true) - self:GetPadding() * 4 ) - 20 )
		pan:SetTall(self.Settings.Size.Value.RowHeight)
		pan:SetText("")

		if (v.Plays == nil ) then
			v.Plays = 0
		end

		pan:SetTooltip( "Likes: " .. v.Likes  .. "\n" .. "Dislikes: " .. v.Dislikes .. "\n" .. "Plays: " .. v.Plays )

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", v.Type or MediaPlayer.MediaTypes.YOUTUBE,  k )
		end

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self:GetWidth(true, true) - 5 )
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor)

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self:GetWidth(true, true) - 5)
		text2:SetPos(5, 20)
		text2:SetText(v.Creator .. " / last played by " .. ( v.Owner.Name or "Unknown" ) .. " (" .. (v.Owner.SteamID or "None" ) .. ")" .. " / last played " .. os.date( "%H:%M:%S - %d/%m/%Y" , v.LastPlayed ))
		text2:SetFont("MediumText")
		text2:SetTextColor(self.Settings.Colours.Value.TextColor)

		self.HistoryGrid:AddItem(pan)
	end
end

--[[
Presents history we get from the server
--]]

function panel:PresentPlayerHistory()
	for k,v in SortedPairsByMemberValue(MediaPlayer.PlayerHistory, "LastPlayed", true ) do

		if (string.sub(k,1,2) == "__") then continue end
		if ( v.Owner == nil ) then v.Owner = {} end

		local pan = vgui.Create("DButton", self.PlayerHistoryGrid )
		pan:SetWide( ( self:GetWidth(true, true) - self:GetPadding() * 4 ) - 20 )
		pan:SetTall(self.Settings.Size.Value.RowHeight)
		pan:SetText("")

		if (v.Plays == nil ) then
			v.Plays = 0
		end

		pan:SetTooltip( "Likes: " .. v.Likes .. "\n" .. "Dislikes: " .. v.Dislikes .. "\n" .. "Plays: " .. v.Plays )

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder )
			surface.DrawOutlinedRect(0, 0, pan:GetWide(), self.Settings.Size.Value.RowHeight, self.Settings.Options.Value.BorderThickness)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", v.Type or MediaPlayer.MediaTypes.YOUTUBE,  k )
		end

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self:GetWidth(true, true) - 5 )
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor )

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self:GetWidth(true, true) - 5)
		text2:SetPos(5, 20)
		text2:SetText(v.Creator .. " / last played " .. os.date( "%H:%M:%S - %d/%m/%Y" , v.LastPlayed ))
		text2:SetFont("MediumText")
		text2:SetTextColor(self.Settings.Colours.Value.TextColor )

		self.PlayerHistoryGrid:AddItem(pan)
	end
end

--[[

--]]

function panel:AddPageHeader(that, page, count)
	page = page or 0
	count = count or MediaPlayer.HistoryCount

	local pan = vgui.Create("DButton", that )
	pan:SetWide( ( self:GetWidth(true, true) - self:GetPadding() * 4 ) - 20  )
	pan:SetTall(self.Settings.Size.Value.RowHeight)
	pan:SetText( "page " .. page)
	pan:SetFont("BigText")
	pan:SetTextColor(self.Settings.Colours.Value.TextColor)

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.HeaderBackground)
		surface.DrawRect(0, 0, pan:GetWide(), pan:GetTall() )
		surface.SetDrawColor(self.Settings.Colours.Value.HeaderBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), pan:GetTall(), self.Settings.Options.Value.BorderThickness )
	end

	that:AddItem(pan)
end

--[[

--]]

function panel:OnEmpty(that)
	local pan = vgui.Create("DButton", that )
	pan:SetWide(self:GetWidth(true, true) - self:GetPadding() * 4 )
	pan:SetTall(self.Settings.Size.Value.RowHeight)
	pan:SetText( "No Results")
	pan:SetFont("BigText")
	pan:SetTextColor(self.Settings.Colours.Value.TextColor)

	pan.Paint = function()
		surface.SetDrawColor(self.Settings.Colours.Value.HeaderBackground)
		surface.DrawRect(0, 0, pan:GetWide(), pan:GetTall() )
		surface.SetDrawColor(self.Settings.Colours.Value.HeaderBorder)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), pan:GetTall(), self.Settings.Options.Value.BorderThickness )
	end

	that:AddItem(pan)
end


--[[

--]]

function panel:RefreshSearchGrid()
	if (IsValid(self.Grid)) then
		self.Grid:Remove()
	end

	self.Grid = vgui.Create("DGrid", self.SearchContainer)
	self.Grid:Dock(FILL)
	self.Grid:SetCols( 1 )
	self.Grid:SetColWide(self:GetWidth())
	self.Grid:SetWide(self:GetWidth())
	self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + self:GetPadding())
end

--[[

--]]

function panel:RefreshHistoryGrid()
	if (IsValid(self.HistoryGrid)) then
		self.HistoryGrid:Remove()
	end

	self.HistoryGrid = vgui.Create("DGrid", self.ServerHistoryContainer)
	self.HistoryGrid:Dock(FILL)
	self.HistoryGrid:SetCols( 1 )
	self.HistoryGrid:SetColWide( self:GetWide() )
	self.HistoryGrid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding())
end

--[[

--]]

function panel:RefreshPlayerGrid()
	if (IsValid(self.PlayerHistoryGrid)) then
		self.PlayerHistoryGrid:Remove()
	end

	self.PlayerHistoryGrid = vgui.Create("DGrid", self.PlayerHistoryContainer)
	self.PlayerHistoryGrid:Dock(FILL)
	self.PlayerHistoryGrid:SetCols( 1 )
	self.PlayerHistoryGrid:SetColWide( self:GetWide() )
	self.PlayerHistoryGrid:SetRowHeight(self.Settings.Size.Value.RowHeight + self:GetPadding())
end

vgui.Register("MediaPlayer.SearchPanel", panel, "MediaPlayer.Base")
