--[[
Settings Panel
------------------------------------------------------------------------------
--]]

local panel = {}

--panel settings
panel.Name = "settings"
panel._Reposition = false

--client settings
panel.ClientSettings = {
	media_create_cl = "Refresh All Panels",
	media_create_playlist_panel = "Refresh Playlist Panel",
	media_create_player_panel = "Refresh Player Panel",
	media_create_search_panel = "Refresh Search Panel",
	media_settings = "Refresh Settings Panel",
	media_search_panel = "Show search panel",
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
	media_reload_chat_commands = "Reload Chat commands",
	media_save_settings = "Save Server Settings",
	media_admin_panel = "Show Admin Panel",
}

panel.Selected = {}

--[[
Init
--]]

function panel:Init()
	self:BaseInit()

	if ( MEDIA.Settings == nil or table.IsEmpty(MEDIA.Settings)) then
		error("no settings")
		return
	end

	self.PropertySheet = vgui.Create("DPropertySheet", self )
	self.PropertySheet:Dock(FILL)
	self.Edited = false

	--Draw our custom colours if we have any
	if (self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		end
	end

	self:SetTitle("Youtube Settings Editor")
end

--[[
Fills the property sheet
--]]

function panel:FillPropertySheet(settings)
	local ply = LocalPlayer()

	for k,v in pairs(settings) do
		if ( k == "Server") then
			if (ply:IsAdmin()) then
				self:AddPropertySheetTab(k, v, "icon16/shield.png", true )
			end
			continue
		else
			self:AddPropertySheetTab(k, v, "icon16/wrench.png", false )
		end
	end

	self:AddCommandsTab()
end

--[[

--]]

function panel:MyThink()
	if (self:HasResized() and MEDIA.Settings != nil ) then
		self.PropertySheet:Remove()
		self.PropertySheet = vgui.Create("DPropertySheet", self )
		self.PropertySheet:Dock(FILL)
		self.Edited = false

		local admin = {}
		if (LocalPlayer():IsAdmin()) then
			admin = MEDIA.AdminSettings
		end

		self:FillPropertySheet({
			Server = admin,
			Client = MEDIA.Settings
		})
	end
end

--[[
Add commands tab
--]]

function panel:AddCommandsTab()

	local pan = vgui.Create("DScrollPanel", self.PropertySheet)
	pan:DockMargin(15,15,15,15)
	pan:Dock(FILL)

	local grid = vgui.Create( "DGrid", pan )
	grid:Dock(FILL)
	grid:SetCols( 1 )
	grid:SetColWide( self:GetWide() )

	local divider = vgui.Create("DButton", grid )
	divider:SetText("Client Commands")
	divider:SetFont("BigText")
	divider:SetTextColor(self.Settings.Colours.Value.TextColor)
	divider:SetWide( self:GetWide() - 65 )
	divider.Paint = function()
	end
	grid:AddItem( divider )

	local fn = function(k,v, image)
		local but = vgui.Create( "DButton", grid )
		but:SetText( "" )
		but:SetFont("MediumText")
		but:SetImage("icon16/" .. image)
		but.Paint = function()
			draw.SimpleTextOutlined( v, "MediumText", 25, 8, self.Settings.Colours.Value.TextColor, 5, 1, 0.5, MEDIA.Colours.Black )
		end
		but:SetWide( self:GetWide() - 65 )
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

	for k,v in pairs(self.ClientSettings) do
		fn(k,v, "user.png")
	end

	if (LocalPlayer():IsAdmin()) then

		--add server commands devicer
		divider = vgui.Create("DButton", grid )
		divider:SetText("Server Commands")
		divider:SetFont("BigText")
		divider:SetTextColor(self.Settings.Colours.Value.TextColor)
		divider.Paint = function()
		end
		divider:SetWide( self:GetWide() - 65 )
		grid:AddItem( divider )

		for k,v in pairs(self.AdminSettings) do
			fn(k, v, "cog.png")
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
	if (icon == nil) then icon = "icon16/star.png" end

	local divider = vgui.Create("DHorizontalDivider", pan )
	divider:Dock(FILL)
	divider:SetDividerWidth( 4 ) -- Set the divider width. Default is 8
	divider:SetLeftMin( 200 ) -- Set the Minimum width of left side
	divider:SetRightMin( 200 )

	local scrollLeft = vgui.Create("DScrollPanel", divider )
	scrollLeft:SetHeight(self:GetTall())
	scrollLeft:DockPadding(5,5,5,5)

	local scrollRight = vgui.Create("DPanel", divider )
	scrollRight:SetHeight(self:GetTall())

	local settingSelection = vgui.Create("DTree", scrollLeft )
	settingSelection:Dock(FILL)
	settingSelection:SetHeight(self:GetTall() - 75)

	scrollLeft:SetVerticalScrollbarEnabled(false)

	if ( !self.settingsEdit) then self.settingsEdit = {} end
	if ( !self.Comments) then self.Comments = {} end

	title = string.Replace(title," ", "_")

	self.settingsEdit[title] = vgui.Create("DProperties", scrollRight)
	self.settingsEdit[title]:Dock(FILL)
	self.settingsEdit[title]:SetHeight(self:GetTall())

	--comment for the property
	self.Comments[title] = vgui.Create("DPanel",self.settingsEdit[title])
	self.Comments[title]:Dock(BOTTOM)
	self.Comments[title]:DockMargin(5,5,5,5)
	self.Comments[title]:DockPadding(5,5,5,5)
	self.Comments[title]:SetTall(65)
	self.Comments[title]:SetBackgroundColor(self.Settings.Colours.Value.Background)
	self.Comments[title]:Hide()

	self.Comments[title].Text = vgui.Create("DLabel",  self.Comments[title])
	self.Comments[title].Text:Dock(FILL)
	self.Comments[title].Text:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Comments[title].Text:SetWrap( true )
	self.Comments[title].Text:SetFont("MediumText")

	for k,keys in SortedPairs(data) do
		for kind,v in SortedPairsByMemberValue(keys, "Convar") do
			local node = settingSelection:AddNode(k)

			function node:DoClick()
				MEDIA.SettingsPanel:UpdateTable(title, v, admin )
			end
		end
	end

	if (admin) then
		self.SendButton = vgui.Create("DButton", scrollRight)
		self.SendButton:Dock(BOTTOM)
		self.SendButton:SizeToContents()
		self.SendButton:SetText("Apply Changes")
		self.SendButton:SetImage("icon16/accept.png")
		self.SendButton:SetTall(30)
		self.SendButton:DockMargin(0,5,5,5)
		self.SendButton:Hide()
		self.SendButton.DoClick = function()
			if (self.Edited) then
				MEDIA.SetAdminSettings()
				self.SendButton:Hide()
				self.Edited = false
			end
		end
	end

	divider:SetLeft(scrollLeft)
	divider:SetRight(scrollRight)

	self.PropertySheet:AddSheet(title, pan, icon)
end

--[[
Updates the selection table
--]]

function panel:UpdateTable(title, v, admin)
	self.settingsEdit[title]:Clear()

	if (v.Comment) then
		local _title = string.Replace(title," ", "_")

		self.Comments[title].Text:SetText(v.Comment)
		self.Comments[title]:Show()
	else
		self.Comments[title]:Hide()
		self:ResizePanel()
	end

	local typ = "Generic"

	if ( v == nil or v.Value == nil) then return end

	if (!istable(v.Value)) then

		local str = v.Key

		if (v.Type == MEDIA.Type.INT ) then
			typ = "Int"
		elseif ( v.Type == MEDIA.Type.BOOL) then
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

			if ( v.Refresh) then
				RunConsoleCommand("media_create_cl")
			end

			if (!admin) then
				if (v.Convar and ConVarExists(v.Key)) then
					if (v.Type == MEDIA.Type.INT) then
						GetConVar(v.Key):SetInt(math.floor(val))
					elseif (v.Type == MEDIA.Type.BOOL) then
						GetConVar(v.Key):SetBool(val)
					elseif (v.Type == MEDIA.Type.STRING ) then
						GetConVar(v.Key):SetString(val)
					end
				end
				MEDIA.Settings[v.Key][v.Type].Value = val

				return
			end
			MEDIA.AdminSettings[v.Key][v.Type].Value = val

			if (self.Edited == false) then
				self.SendButton:Show()
				self.Edited = true
			end
		end

		return
	end

	for k,_v in SortedPairs(v.Value) do
		if (string.sub(k,1,2) == "__") then continue end

		if (tonumber(_v) != nil ) then
			typ = "Int"
		else
			typ = "Generic"
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

--[[
return a normal settings row
--]]

function panel:NormalSettingsRow(v, k, row )
	return function( _, val )
		local fn = function()
			if ( !IsValid(row)) then return end

			local tab = string.Explode(" ",val)

			if (table.IsEmpty(tab) or #tab == 1) then
				tab = val
			end

			if ( MEDIA.Settings[v.Key][v.Type].DefValue.__unpack) then
				MEDIA.Settings[v.Key][v.Type].Value[k] = MEDIA.Settings[v.Key][v.Type].DefValue.__unpack(MEDIA.Settings[v.Key][v.Type], k, tab)
			else
				MEDIA.Settings[v.Key][v.Type].Value[k] = tab
			end

			row:SetValue(MEDIA.Settings[v.Key][v.Type].Value[k])
		end

		if ( v.SlowUpdate ) then
			timer.Remove("update")
			timer.Create("update", v.SlowUpdate, 0, fn)
		else
			fn()
		end
	end
end

--[[
Return an admin settings row
--]]

function panel:AdminSettingsRow(v, k, row )
	return function( _, val )
		local tab = string.Explode(" ",val)

		if (table.IsEmpty(tab) or #tab == 1) then
			tab = val
		end

		if (self.Edited == false) then
			self.SendButton:Show()
			self.Edited = true
		end

		if ( MEDIA.AdminSettings[v.Key][v.Type].DefValue.__unpack) then
			MEDIA.AdminSettings[v.Key][v.Type].Value[k] = MEDIA.AdminSettings[v.Key][v.Type].DefValue.__unpack(MEDIA.AdminSettings[v.Key][v.Type], k, tab)
		else
			MEDIA.AdminSettings[v.Key][v.Type].Value[k] = tab
		end

		row:SetValue(MEDIA.AdminSettings[v.Key][v.Type].Value[k])
	end
end

vgui.Register("MEDIA_Settings", panel, "MEDIA_Base")
