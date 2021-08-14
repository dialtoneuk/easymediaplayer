--[[
Search Panel
------------------------------------------------------------------------------
--]]

local panel = {}

--settings
panel.Name = "search"
panel._Reposition = false

--for the pages
panel.HistoryPage = 1
panel.BrowserHistory = {}
panel.PlayerHistoryPage = 1
panel.BrowserPosition = 0
panel._Empty = false
--[[
	TODO: Branch all this out into more custom vgui elements
--]]

--[[
Fills the property sheet with all our shit
--]]

function panel:Init()
	self:BaseInit()
	self:MakePopup()

	self:SetWide(self.Settings.Size.Value.Width)
	self:SetHeight(self.Settings.Size.Value.Width)
	self:SetDeleteOnClose( false )

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:Dock(FILL)

	self.SearchContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.SearchContainer.Paint = function() end

	self.ServerHistoryContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.ServerHistoryContainer.Paint = function() end

	self.PlayerHistoryContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.PlayerHistoryContainer.Paint = function() end

	self.BrowserContainer = vgui.Create("DScrollPanel", self.PropertySheet )
	self.BrowserContainer.Paint = function() end

	self:CreateBrowserPanel()
	self:CreateSearchPanel()
	self:CreateHistoryPanel()
	self:CreatePlayerHistoryPanel()

	self.PropertySheet:AddSheet("Search", self.SearchContainer, "icon16/wand.png")
	self.PropertySheet:AddSheet("Basic Browser", self.BrowserContainer, "icon16/page_white_world.png")
	self.PropertySheet:AddSheet("Player History", self.PlayerHistoryContainer, "icon16/user.png")
	self.PropertySheet:AddSheet("Server History", self.ServerHistoryContainer, "icon16/shield.png")

	self.PropertySheet.OnActiveTabChanged = function(old, new)

		if (new.Browser != nil ) then
			new.Browser:OpenURL("https://www.youtube.com")
			return
		end

		if (old.Browser != nil ) then
			old.Browser:OpenURL("/")
		end
	end

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end

	self:SetTitle("Youtube Navigator")
end

--[[
Updates the size of our elements basically
--]]

function panel:MyThink()

	self.Grid:SetWide(self.Settings.Size.Value.Width)
	self.Grid:SetColWide(self.Settings.Size.Value.Width)

	if (self:HasResized()) then
		--wide
		self.Browser:SetWide(self.Settings.Size.Value.Width)
		self.Browser:SetTall(self.Settings.Size.Value.Height)

		if (IsValid(self.HistoryGrid)) then
			self.HistoryGrid:SetColWide(self.Settings.Size.Value.Width)
			self.HistoryGrid:SetTall(self.Settings.Size.Value.Height)
			self.HistoryGrid:SetRowHeight(self.Settings.Size.Value.RowHeight + 5 )
		end

		if (IsValid(self.PlayerHistoryGrid)) then
			self.PlayerHistoryGrid:SetColWide(self.Settings.Size.Value.Width)
			self.PlayerHistoryGrid:SetTall(self.Settings.Size.Value.Height)
			self.PlayerHistoryGrid:SetRowHeight( self.Settings.Size.Value.RowHeight + 5 )
		end


		--tall
		self.Grid:SetTall(self.Settings.Size.Value.Height)
		self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + 5 )
	end
end

--[[

--]]

function panel:CreateBrowserPanel()

	local search_func = function(this)
		local val = this:GetValue()

		if (val == "") then
			return
		end

		local result = MEDIA.ParseYoutubeURL(val)

		if (result != nil ) then
			RunConsoleCommand("media_play", result )
			self.Browser:OpenURL("https://www.youtube.com")
		else
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
	self.Browser:SetSize(self.Settings.Size.Value.Width - 25,  self.Settings.Size.Value.Height - 70)
	self.Browser:OpenURL("http://www.youtube.com")
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

		local url = string.sub(str, 9, 29);

		if ( self.BrowserPosition == 2 ) then
			self.BackButton:Show()
		end

		if (!table.HasValue(self.BrowserHistory, str)) then
			table.insert(self.BrowserHistory, #self.BrowserHistory + 1, str)
			self.BrowserPosition = #self.BrowserHistory
		end

		--if its just media or media.com
		if ( url != "www.youtube.com/watch") then
			self.UrlBox:SetValue(str)
			return
		else

			self.UrlBox:SetValue(str)
			self.GrabButton:SetDisabled(false)
			MEDIA.Url = str
		end
	end)

	self.Browser.OnChangeTitle = function(this)
		this:QueueJavascript("console.seturl(document.location.href)")
	end

	self.GrabButton = vgui.Create("DButton", self.Browser)
	self.GrabButton:Dock(BOTTOM)
	self.GrabButton:SetWide(self.Settings.Size.Value.Width - 25)
	self.GrabButton:SetTall(30)
	self.GrabButton:SetImage("icon16/tick.png")
	self.GrabButton:SetText("Grab")
	self.GrabButton:SetDisabled(true)
	self.GrabButton.DoClick = function()

		if (MEDIA.URL == nil) then
			return
		end

		if (MEDIA.URL == "https://www.youtube.com" or MEDIA.URL == "http//www.youtube.com" ) then return end

		timer.Simple(2, function()
			self.GrabButton:SetDisabled(false)
		end)

		local result = MEDIA.ParseYoutubeURL(MEDIA.URL)

		if (result != nil ) then
			RunConsoleCommand("media_play", result )
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
	self.Search:SetPlaceholderText("Will search media.com for valid videos")
	self.Search:DockMargin(15,15,15,15)
	self.Search:SetWide(self.Settings.Size.Value.Width)
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

	if (MEDIA.SearchResults and !table.IsEmpty(MEDIA.SearchResults)) then
		self:PresentSearchResults(false)
	end
end

--[[
Presents our search results
--]]

function panel:PresentSearchResults(clear)

	if (clear) then
		self:RefreshSearchGrid()
	end

	if (!MEDIA.SearchResults) then self:OnEmpty() return end
	if (table.IsEmpty(MEDIA.SearchResults)) then self:OnEmpty() return end

	self.Grid:SetColWide(self.Settings.Size.Value.Width)

	for k,v in pairs(MEDIA.SearchResults) do
		local pan = vgui.Create("DButton", self.Grid )
		pan:SetWide(self.Settings.Size.Value.Width - 40)
		pan:SetHeight(self.Settings.Size.Value.RowHeight)
		pan:SetText("")

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, self.Settings.Size.Value.Width, self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, self.Settings.Size.Value.Width, self.Settings.Size.Value.RowHeight)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", v.Video )
		end

		local html = vgui.Create("DHTML", pan)
		html:Dock(RIGHT)
		html:SetSize( self.Settings.Size.Value.RowHeight * 2, self.Settings.Size.Value.RowHeight)
		html:SetHTML("<style>body{margin:0}</style><img style='width:100%; height: 100%;' src=" .. v.Thumbnail .. "></img>")

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self.Settings.Size.Value.Width - 10 )
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor)

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self.Settings.Size.Value.Width - 10)
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
	self.FetchButton:SetWide( self.Settings.Size.Value.Width)
	self.FetchButton:DockMargin(15,15,15,5)
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
	self.ResetButton:SetWide( self.Settings.Size.Value.Width)
	self.ResetButton:DockMargin(15,5,15,5)
	self.ResetButton.DoClick = function(this)
		self:RefreshHistoryGrid()
		self.HistoryPage = 1
		this:Hide()
	end

	self:RefreshHistoryGrid()

	if (MEDIA.History != nil and !table.IsEmpty(MEDIA.History)) then
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
	self.PlayerFetchButton:SetWide( self.Settings.Size.Value.Width)
	self.PlayerFetchButton:DockMargin(15,15,15,5)
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
	self.PlayerResetButton:SetWide( self.Settings.Size.Value.Width)
	self.PlayerResetButton:DockMargin(15,5,15,5)
	self.PlayerResetButton.DoClick = function(this)
		self:RefreshPlayerGrid()
		self.PlayerHistoryPage = 1
		this:Hide()
	end

	self:RefreshPlayerGrid()

	if (MEDIA.PlayerHistory and !table.IsEmpty(MEDIA.PlayerHistory)) then
		self:PresentPlayerHistory()
	end
end

--[[
Presents history we get from the server
--]]

function panel:PresentHistory()
	for k,v in SortedPairsByMemberValue(MEDIA.History, "LastPlayed", true ) do

		if (string.sub(k,1,2) == "__") then continue end
		if ( v.Owner == nil ) then v.Owner = {} end

		local pan = vgui.Create("DButton", self.HistoryGrid )
		pan:SetWide(self.Settings.Size.Value.Width - 40)
		pan:SetHeight(self.Settings.Size.Value.RowHeight)
		pan:SetText("")
		pan:SetTooltip( "Likes: " .. v.Likes  .. "\n" .. "Dislikes: " .. v.Dislikes .. "\n" .. "Plays: " .. v.Plays )

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, self:GetWide(), self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self.Settings.Size.Value.RowHeight)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", k )

		end

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self.Settings.Size.Value.Width - 10 )
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor)

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self.Settings.Size.Value.Width - 10)
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
	for k,v in SortedPairsByMemberValue(MEDIA.PlayerHistory, "LastPlayed", true ) do

		if (string.sub(k,1,2) == "__") then continue end
		if ( v.Owner == nil ) then v.Owner = {} end

		local pan = vgui.Create("DButton", self.PlayerHistoryGrid )
		pan:SetWide(self:GetWide() - 40)
		pan:SetHeight(self.Settings.Size.Value.RowHeight)
		pan:SetText("")
		pan:SetTooltip( "Likes: " .. v.Likes .. "\n" .. "Dislikes: " .. v.Dislikes .. "\n" .. "Plays: " .. v.Plays )

		pan.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBackground)
			surface.DrawRect(0, 0, self:GetWide(), self.Settings.Size.Value.RowHeight)
			surface.SetDrawColor(self.Settings.Colours.Value.ItemBorder )
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self.Settings.Size.Value.RowHeight)
		end

		pan.DoClick = function()
			RunConsoleCommand("media_play", k )

		end

		local text = vgui.Create("DLabel", pan )
		text:SetWide(self.Settings.Size.Value.Width - 10 )
		text:SetPos(5, 5)
		text:SetText(v.Title)
		text:SetFont("BigText")
		text:SetTextColor(self.Settings.Colours.Value.TextColor )

		local text2 = vgui.Create("DLabel", pan )
		text2:SetWide(self.Settings.Size.Value.Width - 10)
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
	count = count or MEDIA.HistoryCount

	local pan = vgui.Create("DButton", that )
	pan:SetWide(self:GetWide() - 40)
	pan:SetTall(25)
	pan:SetText( "page " .. page)
	pan:SetFont("BigText")
	pan:SetTextColor( MEDIA.Colours.White )

	pan.Paint = function()
		surface.SetDrawColor(MEDIA.Colours.FadedBlack )
		surface.DrawRect(0, 0, pan:GetWide(), pan:GetTall() )
		surface.SetDrawColor(MEDIA.Colours.Red)
		surface.DrawOutlinedRect(0, 0, pan:GetWide(), pan:GetTall() )
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
	self.Grid:SetColWide(self.Settings.Size.Value.Width)
	self.Grid:SetWide(self.Settings.Size.Value.Width)
	self.Grid:SetRowHeight(self.Settings.Size.Value.RowHeight + 5)
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
	self.HistoryGrid:SetRowHeight( self.Settings.Size.Value.RowHeight  + 5 )
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
	self.PlayerHistoryGrid:SetRowHeight(self.Settings.Size.Value.RowHeight + 5 )
end

vgui.Register("MEDIA.SearchPanel", panel, "MEDIA.Base")
