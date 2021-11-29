local panel = {}

panel.Name = "search"

function panel:Init()
	self:BaseInit({
		DontResize = {
			Width = true,
			Height = true
		},
		Declare = {
			VideoID = "",
			URL = ""
		}
	})


	self:SetPaintBackgroundEnabled(false)

	//will hold the buttons and stuff
	self.Navbar = vgui.Create("DPanel", self)
	self.Navbar:SetTall(32)
	self:SetDockPadding(self.Navbar)
	self.Navbar:Dock(TOP)
	self.Navbar.Paint = function(w,h ) end

	self.Browser = vgui.Create("DHTML", self )
	self.Browser:SetSize(self:GetWidth() - 25,  self:GetHeight() - 70)
	self.Browser:DockPadding(5,5,5,5)
	self.Browser:Dock(FILL)

	self.Browser:SetAllowLua(true)

	self.Browser:AddFunction("console", "seturl", function(str)
		self.Submit:SetDisabled(true)

		if (!string.find(str, "https://")) then
			if (!string.find(str, "http://")) then
				return
			end

			str = string.Replace(str, "http://", "https://")
		end

		self.URL = str
		self.TextEntry:SetValue(self.URL)
		str = MediaPlayer.ParseYoutubeURL(str)

		if (str != nil ) then
			self.Submit:SetDisabled(false)
			return
		end
	end)

	self.Browser.OnChangeTitle = function(this)
		this:QueueJavascript("console.seturl(document.location.href)")
	end

	self.TextEntry = vgui.Create("DTextEntry", self.Navbar)
	self.TextEntry:Dock(LEFT)
	self.TextEntry:SetWide(( self:GetWidth() * 0.70 ) - 12)
	self.TextEntry:SetDisabled(true)

	self.Submit = vgui.Create("DButton", self.Navbar)
	self.Submit:Dock(RIGHT)
	self.Submit:SetIcon("icon16/arrow_up.png")
	self.Submit:SetWide(( self:GetWidth() * 0.30 ) - 12)
	self.Submit:SetText("Submit")
	self.Submit:SetDisabled(true)
	self.Submit.DoClick = function(this)
		local str = MediaPlayer.ParseYoutubeURL(self.URL)

		if (str == nil) then
			self.Submit:SetDisabled(true)
			MediaPlayer.CreateWarningBox("Invalid","Invalid Youtube URL", 2)
			return
		end

		RunConsoleCommand("media_play", MediaPlayer.MediaType.YOUTUBE, str)

		self.Submit:SetDisabled(true)
		self.Browser:OpenURL("https://youtube.com")

		MediaPlayer.HidePanel("SearchPanel") //hide the search panel
	end

	self.Browser:OpenURL("https://youtube.com")
end

vgui.Register("MediaPlayer.SearchBrowserContainer", panel, "MediaPlayer.BasePanel")