--[[
Settings Panel
------------------------------------------------------------------------------
--]]

local panel = {}

--panel settings
panel.Name = "settings"

--client settings
panel.ClientSettings = {
	media_create_cl = "Refresh All Panels",
	media_refresh_cl = "Refresh All Panels (Except for this one)",
	media_create_playlist_panel = "Refresh Playlist Panel",
	media_create_player_panel = "Refresh Player Panel",
	media_create_search_panel = "Refresh Search Panel",
	media_create_settings_panel = "Refresh Settings Panel",
	media_write_default_presets = "Rewrite default presets from addon data folder",
	search_panel = "Show search panel",
	media_like_video = "Like Current Video",
	media_dislike_video = "Dislike Current Video",
	media_reset_cl_settings = "Reset Client Settings To Default",
	media_save_cl_settings = "Save Client Settings",
	media_remove_all = "Remove all  your videos"
}

--admin settings
panel.AdminSettings = {
	media_blacklist_video = "Blacklist Current Video",
	media_skip_video = "Skip Current Video",
	media_create_admin_panel = "Refresh Admin Panel",
	media_reset_settings = "Reset Server Settings To Default",
	media_resync_convars = "Sync settings with convars",
	media_reload_cooldowns = "Reload Cooldowns (can fix some time issues)",
	media_reload_playlist = "Reload Playlist (can fix some issues)",
	media_reload_blacklist = "Reload Blacklist",
	media_reload_chatcommands = "Reload Chat Commands",
	media_reload_votes = "Reload Votes",
	media_save_settings = "Save Server Settings",
	admin_panel = "Show Admin Panel",
}

--[[
Init
--]]

function panel:Init()
	self:BaseInit({
		Declare = {
			Selected = {},
			Edited = false,
			Changed = false,
			Clicked = false,
			IsCustom = false, --updated each node select
			IsAdmin = false --updated each node select
		}
	})

	if (!self:IsSettingTrue("AutoResize")) then
		self:SetWide(self:GetWidth())
		self:SetTall(self:GetHeight())
	else
		self:SetIgnoreRescaling(true, true)
		self:RescaleTo(self:GetSettingInt("ResizeScale"))
	end

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:Dock(FILL)
end

function panel:Paint(p)
	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)
	surface.SetDrawColor(self.Settings.Colours.Value.SecondaryBorder)
	surface.DrawOutlinedRect(2, 2, self:GetWide() - 4, self:GetTall() - 4, self.Settings.Options.Value.BorderThickness)
end

--[[
Fills the property sheet
--]]

function panel:FillPropertySheet(settings)
	for k,v in pairs(settings) do
		if ( k == "Server") then
			if (MediaPlayer.LocalPlayer:IsAdmin()) then
				self:AddPropertySheetTab(k, v, "icon16/shield.png", true )
			end
			continue
		else
			self:AddPropertySheetTab(k, v, "icon16/wrench.png", false )
		end
	end

	self:AddCommandsTab()
	self:AddPresetTab()
	self:AddCreditsTab()
end

--[[

--]]

function panel:MyThink()
	if (self:HasRescaled() and MediaPlayer.Settings != nil ) then

		if (!IsValid(self.PropertySheet)) then return end

		self.PropertySheet:Remove()
		self.PropertySheet = vgui.Create("DPropertySheet", self )
		self.PropertySheet:Dock(FILL)
		self.Edited = false
		self.Changed = false

		self:FillPropertySheet({
			Server = MediaPlayer.AdminSettings,
			Client = MediaPlayer.Settings
		})
	end

	if (self:GetWidth() < 300 ) then

		MediaPlayer.CreateWarningBox("Oh no!","Seems the settings window got a bit too small to use. Its only " ..
			math.floor( self:GetWidth() ) .. " pixels wide! We've put it back for you. Try again!")

		self.Settings.Size.Value.Width = 600
		MediaPlayer.ChangeSetting("settings_size", self.Settings.Size.Value)
		MediaPlayer.ChangeSetting("settings_auto_resize", false)

		self:Remove()
		MediaPlayer.InstantiatePanels(true)
	end

	if (self:GetHeight() < 300 ) then

		MediaPlayer.CreateWarningBox("Oh no!","Seems the settings window got a bit too small to use. Its only " ..
			math.floor( self:GetHeight() ) .. " pixels tall! We've put it back for you. Try again!")
		self.Settings.Size.Value.Height = 600
		MediaPlayer.ChangeSetting("settings_size", self.Settings.Size.Value)
		MediaPlayer.ChangeSetting("settings_auto_resize", false)

		self:Remove()
		MediaPlayer.InstantiatePanels(true)
	end
end

--[[
Add Preset tab
--]]

function panel:AddPresetTab()

	self.PresetEditor = vgui.Create("MediaPlayer.SettingPresets", self.PropertySheet)
	self.PropertySheet:AddSheet("Presets", self.PresetEditor, "icon16/folder.png")
end

--[[
Add Credits Tab
--]]

function panel:AddCreditsTab()

	local p = vgui.Create("DPanel", self.PropertySheet)
	p:Dock(FILL)
	self:SetDockMargin(p)

	local html = vgui.Create("DHTML", p)
	html:Dock(FILL)
	html:SetHTML([[
		<html>
			<head>
				<style>
					html{
						font-family: Arial, Helvetica, sans-serif;
						text-align: center;
						padding: 15%;
					}
				</style>
			</head>
			<body>
				<h1>made by lyds</h1>

				<marquee>8=========3</marquee>

				<h2>Github<h2>
				https://github.com/dialtoneuk/easymediaplayer

				<h2>My Twitter</h2>
				https://twitter.com/lydsmas

				<h2>Send Eth</h2>
				0x527738Dd42170065d778C89264654b03f8Ed989B
			</body>
		</html>
	]])

	self.PropertySheet:AddSheet("Credits & Changelog", p, "icon16/rainbow.png")
end

--[[
Add commands tab
--]]

function panel:AddCommandsTab()
	local pan = vgui.Create("DScrollPanel", self.PropertySheet)
	self:SetDockMargin(pan)

	pan:Dock(FILL)

	local grid = vgui.Create( "DGrid", pan )
	grid:Dock(FILL)
	grid:SetCols( 1 )
	grid:SetColWide( self:GetWide() )
	grid:SetRowHeight( self.Settings.Size.Value.RowHeight + self:GetPadding() )
	self:SetDockPadding(grid)
	self:SetDockMargin(grid)

	local divider = vgui.Create("DButton", grid )
	divider:SetText("")
	divider:SetFont("BigText")
	divider:SetTextColor(self.Settings.Colours.Value.TextColor)
	divider:SetTall( self.Settings.Size.Value.RowHeight)
	divider:SetWide( ( self:GetWidth(true, true ) - self:GetPadding() * 2 )  - 30 )

	divider.Paint = function()
		draw.SimpleTextOutlined( "Client Commands", "BiggerText", 5, self.Settings.Size.Value.RowHeight / 2 , self.Settings.Colours.Value.TextColor, 5, 1, 0.5, MediaPlayer.Colours.Black )
	end

	grid:AddItem( divider )

	local fn = function(k,v, image)
		local but = vgui.Create( "DButton", grid )
		but:SetText( "" )
		but:SetFont("BigText")
		but:SetImage("icon16/" .. image)
		but:SetTall( self.Settings.Size.Value.RowHeight)
		but:SetWide( ( self:GetWidth(true, true ) - self:GetPadding() * 2 )  - 30 )

		but.Paint = function(s)
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, s:GetWide(), self.Settings.Size.Value.RowHeight , self.Settings.Options.Value.BorderThickness)
			draw.SimpleTextOutlined( v, "MediumText", 25, self.Settings.Size.Value.RowHeight / 2, self.Settings.Colours.Value.TextColor, 5, 1, 0.5, MediaPlayer.Colours.Black )
		end


		but.DoClick = function(_s)
			_s:SetDisabled(true)
			_s:SetImage("icon16/tick.png")

			timer.Simple(1, function()
				if (!IsValid(_s)) then return end
				_s:SetDisabled(false)
				_s:SetImage("icon16/arrow_refresh.png")
			end)

			RunConsoleCommand(k)
		end

		grid:AddItem( but )
	end

	for k,v in SortedPairs(self.ClientSettings) do
		fn(k,string.upper(v), "user.png")
	end

	if (MediaPlayer.LocalPlayer:IsAdmin()) then

		--add server commands devicer
		divider = vgui.Create("DButton", grid )
		divider:SetText("")
		divider:SetFont("BigText")
		divider:SetTall( self.Settings.Size.Value.RowHeight)
		divider:SetWide( ( self:GetWidth(true, true ) - self:GetPadding() * 2 )  - 30 )
		divider:SetTextColor(self.Settings.Colours.Value.TextColor)

		divider.Paint = function()
			draw.SimpleTextOutlined( "Server Commands", "BiggerText", 5, self.Settings.Size.Value.RowHeight / 2 , self.Settings.Colours.Value.TextColor, 5, 1, 0.5, MediaPlayer.Colours.Black )
		end

		grid:AddItem( divider )

		for k,v in SortedPairs(self.AdminSettings) do
			fn(k, string.upper(v), "cog.png")
		end
	end

	self.PropertySheet:AddSheet("Commands", pan, "icon16/star.png")
end

--[[
Adds a new property sheet tab, takes settings data
--]]

function panel:AddPropertySheetTab(title, data, icon, admin)
	admin = admin or false

	local pan = vgui.Create("DPanel", self.PropertySheet)
	pan.Paint = function() end

	self:SetDockPadding(pan)

	if (icon == nil) then icon = "icon16/star.png" end

	local divider = vgui.Create("DHorizontalDivider", pan )
	divider:Dock(FILL)
	divider:SetDividerWidth( 8 ) -- Set the divider width. Default is 8
	divider:SetLeftMin( math.floor(self:GetWidth() / 3) + self:GetPadding() * 4 ) -- Set the Minimum width of left side
	divider:SetRightMin( 200 )

	local scrollRight = vgui.Create("DPanel", divider )
	scrollRight:SetHeight(self:GetTall())
	scrollRight._Paint = scrollRight.Paint

	scrollRight.Paint = function(s)

		if (admin and self.Edited) then
			draw.SimpleTextOutlined( "Remember to click save!" , "BiggerText", 10, s:GetTall() / 2 , MediaPlayer.Colours.White, 10, 1, 0.5,  MediaPlayer.Colours.Black )
		end
	end

	local settingSelection = vgui.Create("DTree", divider)
	settingSelection:SetHeight(self:GetTall() - 75)


	if ( !self.settingsEdit) then self.settingsEdit = {} end
	if ( !self.Comments) then self.Comments = {} end
	if ( !self.Notifications) then self.Notifications = {} end

	title = string.Replace(title," ", "_")

	self.settingsEdit[title] = vgui.Create("DProperties", scrollRight)
	self.settingsEdit[title]:Dock(FILL)
	self.settingsEdit[title]:SetHeight(self:GetTall())
	self.settingsEdit[title]:DockMargin(0, self:GetPadding() * 2, 0, 0)

	--refreshes all panels
	self.RefreshAllPanels = vgui.Create("DButton", scrollRight)
	self.RefreshAllPanels:Dock(TOP)
	self.RefreshAllPanels:SizeToContents()
	self.RefreshAllPanels:SetText("Refresh All Panels")
	self.RefreshAllPanels:SetImage("icon16/arrow_refresh.png")
	self.RefreshAllPanels:SetTall(30)
	self.RefreshAllPanels:DockMargin(0,self:GetPadding(),0,0)
	self.RefreshAllPanels.DoClick = function()
		RunConsoleCommand("media_create_cl")

		MediaPlayer.CreateChatMessage("Refreshed all panels! Settings window reopening in a second...")

		--
		timer.Simple(1, function()
			if (MediaPlayer.PanelValid("SettingsPanel")) then
				MediaPlayer.ShowPanel("SettingsPanel")
			end
		end)
	end

	if (admin) then
		self.SendButton = vgui.Create("DButton", scrollRight)
		self.SendButton:Dock(BOTTOM)
		self.SendButton:SizeToContents()
		self.SendButton:SetText("Save Changes")
		self.SendButton:SetImage("icon16/accept.png")
		self.SendButton:SetTall(30)
		self.SendButton:DockMargin(0,5,0,0)
		self.SendButton:Hide()
		self.SendButton.DoClick = function()
			if (self.Edited) then
				MediaPlayer.SetAdminSettings()

				self.SendButton:SetDisabled(true)
				self.Edited = false
				self.Changed = false
				MediaPlayer.CreateSuccessBox("Success","Server settings succesfully applied", 2)
			end
		end
	else

		self.Reset = vgui.Create("DButton", scrollRight)
		self.Reset:Dock(TOP)
		self.Reset:SizeToContents()
		self.Reset:SetText("Reset Setting To Default")
		self.Reset:SetImage("icon16/key.png")
		self.Reset:SetTall(30)
		self.Reset:SetDisabled(true)
		self.Reset:DockMargin(0,self:GetPadding(),0,0)
		self.Reset.DoClick = function()
			if (self.Selected == nil or self.Selected.Key == nil ) then return end

			--resets
			MediaPlayer.ResetSetting(self.Selected.Key)

			self:UpdateTable(title, MediaPlayer.GetSetting(self.Selected.Key), self.IsAdmin)

			--self:UpdateTable(title, setting, false)
			MediaPlayer.CreateSuccessBox("Success", "Setting '" .. self.Selected.Key .. "' has sucessfully been reset. You might need to refresh all panels.")
		end
	end

	self.AddKey = vgui.Create("DButton", scrollRight)
	self.AddKey:Dock(TOP)
	self.AddKey:SizeToContents()
	self.AddKey:SetText("Add New Key")
	self.AddKey:SetImage("icon16/key.png")
	self.AddKey:SetTall(30)
	self.AddKey:SetDisabled(true)
	self.AddKey:DockMargin(0,self:GetPadding(),0,0)
	self.AddKey.DoClick = function()
		if (!self.IsCustom) then
			MediaPlayer.CreateWarningBox("Error", "This table is uncustomizable")
			return
		else
			if (self.Selected == nil or self.Selected.Key == nil ) then return end

			local setting

			if (self.IsAdmin) then
				setting =  MediaPlayer.GetSetting(self.Selected.Key)
			else
				setting = MediaPlayer.AdminSettings[self.Selected.Key][self.Selected.Type]
			end

			if (setting != MediaPlayer.Type.TABLE ) then error("not a table") return end
			if (!setting.Custom ) then error("not customisable") return end

			setting.Value[#setting.Value + 1] = ""
			self:UpdateTable(title, setting, self.IsAdmin)
		end
	end

	--comment for the property
	self.Comments[title] = vgui.Create("DPanel",self.settingsEdit[title])
	self.Comments[title]:Dock(BOTTOM)
	self.Comments[title]:DockMargin(0,5,0,0)
	self.Comments[title]:DockPadding(15,5,5,5)
	self.Comments[title]:SetTall(85)
	self.Comments[title]:SetBackgroundColor(self.Settings.Colours.Value.Background)
	self.Comments[title]:Hide()

	self.Comments[title].Text = vgui.Create("DLabel",  self.Comments[title])
	self.Comments[title].Text:Dock(FILL)
	self.Comments[title].Text:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Comments[title].Text:SetWrap( true )
	self.Comments[title].Text:SetFont("MediumText")

	self.Notifications[title] = vgui.Create("DPanel",self.settingsEdit[title])
	self.Notifications[title]:Dock(BOTTOM)
	self.Notifications[title]:DockMargin(0,5,0,0)
	self.Notifications[title]:DockPadding(15,5,5,5)
	self.Notifications[title]:SetTall(30)
	self.Notifications[title]:SetBackgroundColor(MediaPlayer.Colours.FadedRed)
	self.Notifications[title]:Hide()

	self.Notifications[title].Text = vgui.Create("DLabel",  self.Notifications[title])
	self.Notifications[title].Text:Dock(FILL)
	self.Notifications[title].Text:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Notifications[title].Text:SetWrap( true )
	self.Notifications[title].Text:SetFont("MediumText")

	for k,keys in SortedPairs(data) do
		for kind,v in SortedPairsByMemberValue(keys, "Convar") do
			local node = settingSelection:AddNode(k, MediaPlayer.GetSettingIcon(k, admin) )

			function node:DoClick()
				if (!MediaPlayer.PanelValid("SettingsPanel")) then return end

				local s = MediaPlayer.GetPanel("SettingsPanel")
				s:UpdateTable(title, v, admin )
				s.Selected = v
				s.IsCustom = v.Custom or false
				s.IsAdmin = admin
				s.AddKey:SetDisabled(!self.IsCustom)
				s.Reset:SetDisabled(false)
			end
		end
	end

	divider:SetLeft(settingSelection)
	divider:SetRight(scrollRight)

	self.PropertySheet:AddSheet(title, pan, icon)
end

--[[
Updates the selection table
--]]

function panel:UpdateTable(title, v, admin)
	self.settingsEdit[title]:Clear()

	local settingsTitle = string.Replace(title," ", "_")

	if (v.Comment) then
		self.Comments[title].Text:SetText(settingsTitle .. ": " .. MediaPlayer.AddFullStop(v.Comment))
		self.Comments[title]:Dock(BOTTOM)
		self.Comments[title]:Show()
	else
		self.Comments[title]:Hide()
	end

	if (v.Refresh != true) then
		self.Notifications[title].Text:SetText("You will need to refresh all panels after changing this setting.")
		self.Notifications[title]:Dock(BOTTOM)
		self.Notifications[title]:Show()
	elseif (v.SlowUpdate) then
		self.Notifications[title].Text:SetText("This setting once edited will update all client panels after " .. v.SlowUpdate .. " seconds.")
		self.Notifications[title]:Dock(BOTTOM)
		self.Notifications[title]:Show()
	elseif (v.Dangerous) then
		self.Notifications[title].Text:SetText("This setting is dangerous! Only change it if you know what you are doing.")
		self.Notifications[title]:Dock(BOTTOM)
		self.Notifications[title]:Show()
	else
		self.Notifications[title]:Hide()
	end

	local typ = "Generic"

	if ( v == nil or v.Value == nil) then return end

	if (!istable(v.Value)) then

		local str = v.Key

		if (v.Type == MediaPlayer.Type.INT ) then
			typ = "Int"
		elseif (v.Type == MediaPlayer.Type.FLOAT ) then
			typ = "Float"
		elseif ( v.Type == MediaPlayer.Type.BOOL) then
			typ = "Boolean"
		end

		if (v.Convar) then
			str = "(convar) " .. v.Key
		end

		local row = self.settingsEdit[title]:CreateRow(str, typ)

		if (typ == "Int") then
			row:Setup(typ, { min = v.Min or 0, max = v.Max or 10000 } )
		else
			row:Setup(typ)
		end

		row:SetValue(v.Value)
		row.DataChanged = function( _, val )

			if (v.Refresh and !admin) then

				local fn = function()
					RunConsoleCommand("media_refresh_cl")
				end

				if ( v.SlowUpdate ) then

					local t

					if (type(v.SlowUpdate) == "boolean") then
						t = 0.1
					else
						t = v.SlowUpdate
					end

					timer.Remove("update")
					timer.Create("update", t, 1, fn)
				else
					fn()
				end
			end

			if (!admin) then
				if (MediaPlayer.GetSetting(v.Key).Value != val ) then
					MediaPlayer.ChangeSetting(v.Key, val)
				end

				return
			end

			MediaPlayer.AdminSettings[v.Key][v.Type].Value = val

			if (self.Edited == false) then

				self.SendButton:SetDisabled(false)
				self.SendButton:Show()
				self.Edited = true
				self.Changed = true
			end
		end

		return
	end

	for k,_v in pairs(v.Value) do
		if (type(k) == "string" and string.sub(k,1,2) == "__") then continue end

		if (type(_v) == "number") then
			typ = "Int"
		elseif (type(_v) == "boolean") then
			typ = "Boolean"
		elseif (type(_v) == "string") then
			typ = "Generic"
		else
			typ = "Int"
		end

		if (IsColor(_v)) then
			typ = "VectorColor"
		end

		local row = self.settingsEdit[title]:CreateRow(k, typ)

		if (typ == "Int") then
			row:Setup(typ, { min = v.Min or 0, max = v.Max or 2000 } )
		else
			row:Setup(typ)
		end

		row:SetValue(_v)

		if (!admin) then
			row.DataChanged = self:NormalSettingsRow(v, k, row )
		else
			row.DataChanged = self:AdminSettingsRow(v, k, row )
		end
	end
end

--[[`
return a normal settings row
--]]

function panel:NormalSettingsRow(v, k, row )

	self.Clicked = true

	return function( _, val )
		local fn = function()
			if ( !IsValid(row)) then return end

			local tab = string.Explode(" ",val)

			if (table.IsEmpty(tab) or #tab == 1) then
				tab = val
			end

			if ( MediaPlayer.Settings[v.Key][v.Type].DefValue.__unpack) then
				MediaPlayer.Settings[v.Key][v.Type].Value[k] = MediaPlayer.Settings[v.Key][v.Type].DefValue.__unpack(MediaPlayer.Settings[v.Key][v.Type], k, tab)
			else

				if (type(MediaPlayer.Settings[v.Key][v.Type].DefValue[k]) == "boolean") then
					tab = (tab == 1 or tab == true)
					MediaPlayer.Settings[v.Key][v.Type].Value[k] = tab
					return
				end

				if (v.Type == MediaPlayer.Type.TABLE) then
					MediaPlayer.Settings[v.Key][v.Type].Value[k] = val
				elseif (v.Type == MediaPlayer.Type.INT) then
					MediaPlayer.Settings[v.Key][v.Type].Value[k] = math.Truncate(tab)
				elseif (v.Type == MediaPlayer.Type.FLOAT) then
					MediaPlayer.Settings[v.Key][v.Type].Value[k] = math.Truncate(tab, 2)
				else
					MediaPlayer.Settings[v.Key][v.Type].Value[k] = tab
				end
			end

			row:SetValue(MediaPlayer.Settings[v.Key][v.Type].Value[k])
		end

		if ( v.SlowUpdate ) then

			local t

			if (type(v.SlowUpdate) == "boolean") then
				t = 0.1
			else
				t = v.SlowUpdate
			end

			timer.Remove("update")
			timer.Create("update", t, 1, fn)
		else
			fn()
		end
	end
end

--[[
Return an admin settings row
--]]

function panel:AdminSettingsRow(v, k, row )

	self.Clicked = true

	return function( _, val )
		local tab = string.Explode(" ",val)

		if (table.IsEmpty(tab) or #tab == 1) then
			tab = val
		end

		if (self.Edited == false) then
			self.SendButton:Show()
			self.Edited = true
		end

		self.Changed = true

		if ( MediaPlayer.AdminSettings[v.Key][v.Type].DefValue.__unpack) then
			MediaPlayer.AdminSettings[v.Key][v.Type].Value[k] = MediaPlayer.AdminSettings[v.Key][v.Type].DefValue.__unpack(MediaPlayer.AdminSettings[v.Key][v.Type], k, tab)
		else

			--seems to work for boolean packing/unpacking
			if (type(MediaPlayer.AdminSettings[v.Key][v.Type].DefValue[k]) == "boolean") then
				tab = (tab == 1 or tab == true)
				MediaPlayer.AdminSettings[v.Key][v.Type].Value[k] = tab
				return
			end

			if (v.Type == MediaPlayer.Type.TABLE) then
				MediaPlayer.AdminSettings[v.Key][v.Type].Value[k] = val
			elseif (v.Type == MediaPlayer.Type.INT) then
				MediaPlayer.AdminSettings[v.Key][v.Type].Value[k] = math.Truncate(tab)
			else
				MediaPlayer.AdminSettings[v.Key][v.Type].Value[k] = tab
			end
		end
	end
end

vgui.Register("MediaPlayer.SettingsPanel", panel, "MediaPlayer.Base")
