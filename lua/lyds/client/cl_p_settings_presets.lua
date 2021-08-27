local panel = {}

panel.Name = "settings"

panel.DefaultSettings = {
	Panels = {
		"warning",
		"success",
		"base",
		"settings",
		"player",
		"playlist",
		"admin",
		"vote",
		"search"
	},
	Keys = {
		"colours",
		"size",
		"position",
		"options",
		"invert_position",
		"auto_resize",
		"resize_scale"
	}
}

function panel:Init()
	self:BaseInit({
		Locked = true,
		Padding = true,
		DontResize = {
			Width = true,
			Height = true
		},
		Declare = {
			Presets = {},
			LastListView = nil
		}
	})

	self:Dock(FILL)

	self.ListView = vgui.Create("DListView", self )
	self.ListView:Dock(LEFT)
	self.ListView:SetWide( ( self:GetWidth() / 3 ) - ( self:GetPadding() * 2 ) )
	self.ListView:SetTall( self:GetHeight() )
	self.ListView:AddColumn("Presets")

	self:SetDockMargin(self.ListView)

	self.ListView.OnRowSelected = function(p, index, row)
		local k = row:GetValue(1)

		if (self.PresetCreator:IsVisible()) then
			self.PresetCreator:Hide()
			self:CreateAddButton()
		end

		if (self.LastListValue == k ) then
			self.PresetEditor:Show()
			return
		end
		if (!self.Presets[k]) then
			error(k .. "not set in presets")
		else
			self.LastListValue = k

			if (k == "server_preset.json" and !MediaPlayer.LocalPlayer:IsAdmin()) then
				return
			end

			self.Preset = self.Presets[k]
			self:FillPresetEditor()
			self.PresetEditor:Show()
		end
	end

	--help button
	local help = vgui.Create("DButton", self.ListView )
	help:SetTall(15)
	help:Dock(BOTTOM)
	help:SetText("Help")
	self:SetDockMargin(help)

	--creates add button
	self:CreateAddButton()

	self.PresetEditor = vgui.Create("DPanel", self )
	self.PresetEditor:Dock(RIGHT)
	self.PresetEditor:SetTall( self:GetHeight() )
	self.PresetEditor:SetWide( self.ListView:GetWide() * 2 - ( self:GetPadding() * 2 ))
	self.PresetEditor:Hide()
	self.PresetEditor.Paint = function() end
	self:SetDockMargin(self.PresetEditor)

	self.PresetCreator = vgui.Create("DPanel", self )
	self.PresetCreator:Dock(RIGHT)
	self.PresetCreator:SetTall( self:GetHeight() )
	self.PresetCreator:SetWide( self.ListView:GetWide() * 2 - ( self:GetPadding() * 2 ))
	self.PresetCreator:Hide()
	self.PresetCreator.Paint = function() end
	self:SetDockMargin(self.PresetCreator)

	self:GetPresets()
end

function panel:Paint(p)
	--nothing
end

function panel:CreateAddButton()
	local add = vgui.Create("DButton", self.ListView)
	add:Dock(BOTTOM)
	add:SetTall(15)
	add:SetText("New Preset")

	add.DoClick = function(s)
		s:Remove()

		self.PresetEditor:Hide()

		if (!IsValid(self.PresetTitle)) then
			self:FillPresetCreator()
		else
			self.PresetTitle:SetValue("")
			self.PresetTitle:SetPlaceholderText("untitled")
		end

		self.PresetCreator:Show()
	end

	self:SetDockMargin(add)
end

function panel:FillPresetCreator()
	local label_title = vgui.Create("DLabel", self.PresetCreator)
	label_title:Dock(TOP)
	label_title:SetText("Preset Title (must be unique and alphabetical containing no special characters)")
	label_title:SetTextColor(self.Settings.Colours.Value.TextColor)

	self.PresetTitle = vgui.Create("DTextEntry", self.PresetCreator)
	self.PresetTitle:Dock(TOP)
	self.PresetTitle:SetPlaceholderText("untitled")

	local label_author = vgui.Create("DLabel", self.PresetCreator)
	label_author:Dock(TOP)
	label_author:SetText("Author")

	self.PresetAuthor = vgui.Create("DTextEntry", self.PresetCreator)
	self.PresetAuthor:Dock(TOP)
	self.PresetAuthor:DockMargin( 0, 0, 0, self:GetPadding() )
	self.PresetAuthor:SetValue( MediaPlayer.LocalPlayer:Name() )

	self.Checkbox = vgui.Create("DCheckBoxLabel", self.PresetCreator )
	self.Checkbox:Dock(TOP)
	self.Checkbox:SetText("Initiate with some default settings such as the size, position and colour of all elements")
	self.Checkbox:SetValue( true )
	self.Checkbox:SizeToContents()
	self.Checkbox:DockMargin( 0, 0, 0, self:GetPadding() )

	local add = vgui.Create("DButton", self.PresetCreator)
	add:Dock(TOP)
	add:SetTall(30)
	add:DockMargin(0, self:GetPadding(), 0, 0 )
	add:SetText("Create Preset")

	add.DoClick = function(s)
		local result = self:CreatePreset(self.PresetTitle:GetValue(), self.PresetAuthor:GetValue(), self.Checkbox:GetChecked())

		if (!result) then
			MediaPlayer.CreateWarningBox("Unsuccessful","Please make sure the title is not taken by something else and it also doesn't contain any special characters. Please change: " .. self.PresetTitle:GetValue())
		else
			self.ListView:AddLine(result)
			self.PresetCreator:Hide()
			self:CreateAddButton()
		end
	end
end

function panel:CreatePreset(title, author, add_default)

	title = string.Trim(title)
	title = string.Replace(title, " ", "_")
	title = string.Replace(title, "[", "")
	title = string.Replace(title, "]", "")
	title = string.Replace(title, "%", "")
	title = string.Replace(title, ".json", "")
	title = string.lower(title)

	if (title == "" or title == "_"  or string.len(title) > 52) then
		return false
	end

	--any special chars
	if (string.match(title, "[\\/:;*£-+`=$?\".@#~+^,()!{}<>|]")) then
		return false
	end

	local settings = {}

	if (add_default) then
		for k,v in pairs(self.DefaultSettings.Panels) do
			for _,setting in pairs(self.DefaultSettings.Keys) do
				settings[v .. "_" .. setting] = MediaPlayer.GetSetting(v .. "_" .. setting).Value
			end
		end
	end

	local preset =  {
		Author = author,
		Locked = false,
		Description = "User created preset",
		Version = MediaPlayer.Version,
		Settings = settings
	}

	if (file.Exists("lyds/presets/" .. title .. ".json", "DATA")) then
		return false
	end

	MediaPlayer.SavePreset(title, table.Copy(preset))
	self.Presets[title .. ".json"] = table.Copy(preset)

	return title .. ".json"
end

function panel:GetPresets()

	if (!file.IsDir("lyds/presets","DATA")) then
		file.CreateDir("lyds/presets")
		return
	end

	local files = file.Find("lyds/presets/*.json", "DATA")

	if (!table.IsEmpty(files)) then
		for k,v in pairs(files) do
			local result = util.JSONToTable(file.Read("lyds/presets/" .. v, "DATA"))
			if (result == nil or table.IsEmpty(result) or result.Settings == nil ) then
				warning("there was an issue parsing the preset file called ", v)
				continue
			end

			self.Presets[v] = result
		end

		if (!table.IsEmpty(self.Presets)) then
			for k,v in pairs(self.Presets) do
				self.ListView:AddLine(k)
			end
		end
	end
end

function panel:FillPresetEditor()

	if (self.Preset == nil or table.IsEmpty(self.Preset)) then return end
	if (IsValid(self.CurrentPreset)) then self.CurrentPreset:Remove() end

	self.CurrentPreset = vgui.Create("DPanel", self.PresetEditor )
	self.CurrentPreset:Dock(FILL)
	self.CurrentPreset:SetPaintBackgroundEnabled(false)

	self:SetDockPadding(self.CurrentPreset)
	self:SetDockMargin(self.CurrentPreset)

	local listview = vgui.Create("DListView", self.CurrentPreset)
	listview:Dock(LEFT)
	listview:SetWide( math.floor( self.PresetEditor:GetWide() / 2 ) - ( self:GetPadding() * 2 ) )
	listview:AddColumn("Included Settings")

	self.LastValue = nil

	listview.OnRowSelected = function(p, index, row )
		local k = row:GetValue(1)

		if (!self:IsPresetLocked()) then
			self.RemoveButton:SetDisabled(false)
			self.UpdateButton:SetDisabled(false)
			self.SaveButton:SetDisabled(false)
		end

		if (IsValid(self.PresetPreview) and self.LastValue != k ) then
			self.PresetPreview:DisplaySettings(k, self.Preset.Settings[k], self)
			self.LastValue = k
		end

	end

	if (self.Preset.Settings != nil and !table.IsEmpty(self.Preset.Settings)) then
		for k,v in pairs(self.Preset.Settings) do
			if (!MediaPlayer.HasSetting(k)) then
				self.Preset.Settings[k] = nil
				continue
			end
			if (k != nil ) then
				listview:AddLine(k)
			end
		end
	end

	--container
	local p = vgui.Create("DPanel", self.CurrentPreset)
	p:Dock(RIGHT)
	p:SetWide( math.floor( self.PresetEditor:GetWide() / 2 ) - ( self:GetPadding() * 2 ) )
	p.Paint = function()
	end

	self:SetDockPadding(p)

	if (IsValid(self.ComboBox)) then self.ComboBox:Remove() end

	self.ComboBox = vgui.Create( "DComboBox", p )
	self.ComboBox:SetTall(30)
	self.ComboBox:Dock(TOP)
	self.ComboBox:SetValue( "..." )

	for k,v in pairs(MediaPlayer.Settings) do
		self.ComboBox:AddChoice(k)
	end

	self.ComboBox.OnSelect = function( s, index, value )
		if (self:IsPresetLocked()) then
			return
		end

		self.AddButton:SetDisabled(false)
	end

	if (self:IsPresetLocked()) then
		self.ComboBox:SetDisabled(true)
	end

	if (IsValid(self.VersionText)) then self.VersionText:Remove() end

	self.VersionText = vgui.Create("DLabel", p )
	self.VersionText:SetTall(15)
	self.VersionText:Dock(TOP)
	self.VersionText:DockMargin(0,self:GetPadding(),0,0)
	self.VersionText:SetText( "Version: " .. ( self.Preset.Version or "Unknown?") )
	self.VersionText:SetTextColor(MediaPlayer.Colours.Black)

	if (IsValid(self.AddButton)) then self.AddButton:Remove() end

	self.AddButton = vgui.Create("DButton", p )
	self.AddButton:SetTall(30)
	self.AddButton:Dock(TOP)
	self.AddButton:SetDisabled(true)
	self.AddButton:DockMargin(0,self:GetPadding(),0,self:GetPadding() * 2)
	self.AddButton:SetText("Add Setting")

	self.AddButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end

		local sel = self.ComboBox:GetSelected()

		if ( sel != nil and sel != "..." ) then

			local tab = table.Copy(MediaPlayer.GetSetting(sel))
			self.Preset.Settings[sel] = tab.Value
			self.HasEdited = true
			self:FillPresetEditor()
		end
	end

	if (IsValid(self.RemoveButton)) then self.RemoveButton:Remove() end

	self.RemoveButton = vgui.Create("DButton", p )
	self.RemoveButton:SetTall(20)
	self.RemoveButton:Dock(TOP)
	self.RemoveButton:SetDisabled(true)
	self.RemoveButton:DockMargin(0,self:GetPadding(),0,self:GetPadding() * 2)
	self.RemoveButton:SetText("Remove Setting")

	self.RemoveButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end

		local sel = self.LastValue or nil

		if ( sel != nil ) then
			self.Preset.Settings[sel] = nil
			self:FillPresetEditor()
			self.HasEdited = true
		end
	end

	if (IsValid(self.UpdateButton)) then self.UpdateButton:Remove() end

	self.UpdateButton = vgui.Create("DButton", p )
	self.UpdateButton:SetTall(15)
	self.UpdateButton:Dock(TOP)
	self.UpdateButton:SetDisabled(true)
	self.UpdateButton:DockMargin(0,self:GetPadding(),0,0)
	self.UpdateButton:SetTall(20)
	self.UpdateButton:SetText("Set Setting To Current Setting")

	self.UpdateButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end


		local sel = self.LastValue or nil

		if ( sel != nil and sel != "..." ) then

			local tab = table.Copy(MediaPlayer.GetSetting(sel))
			self.Preset.Settings[sel] = tab.Value
			self.HasEdited = true
			self:FillPresetEditor()
		end
	end

	if (IsValid(self.UpdateAllButton)) then self.UpdateAllButton:Remove() end

	self.UpdateAllButton = vgui.Create("DButton", p )
	self.UpdateAllButton:SetTall(15)
	self.UpdateAllButton:Dock(TOP)
	self.UpdateAllButton:SetDisabled(true)
	self.UpdateAllButton:DockMargin(0,self:GetPadding(),0,0)
	self.UpdateAllButton:SetTall(30)
	self.UpdateAllButton:SetText("Sync All Settings To Current")

	self.UpdateAllButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end

		self.HasEdited = true

		for k,v in pairs(self.Preset.Settings) do
			local tab = table.Copy(MediaPlayer.GetSetting(k))
			self.Preset.Settings[k] = tab.Value
			self:FillPresetEditor()
		end
	end

	if (!self:IsPresetLocked() ) then
		self.UpdateAllButton:SetDisabled(false)
	end

	if (IsValid(self.PresetPreview)) then self.PresetPreview:Remove() end

	self.PresetPreview = vgui.Create("MediaPlayer.PresetPreview", p )
	self.PresetPreview:Dock(TOP)
	self.PresetPreview:DockMargin(0, self:GetPadding() * 2, 0, 0)
	self.PresetPreview:SetTall(self:GetHeight() / 3)

	if (IsValid(self.LoadButton)) then self.LoadButton:Remove() end

	self.LoadButton = vgui.Create("DButton", p )
	self.LoadButton:SetTall(30)
	self.LoadButton:Dock(BOTTOM)
	self.LoadButton:DockMargin(0,self:GetPadding(),0,0)
	self.LoadButton:SetText("Apply Preset")
	self.LoadButton.DoClick = function()
		MediaPlayer.ApplyPreset(self.Preset)
		RunConsoleCommand("media_create_cl")

		MediaPlayer.CreateSuccessBox("Success","Preset " .. self.LastListValue .. " successfully applied")
		RunConsoleCommand("settings")
	end

	if (MediaPlayer.LocalPlayer:IsAdmin() ) then

		if (IsValid(self.DefaultButton)) then self.DefaultButton:Remove() end

		self.DefaultButton = vgui.Create("DButton", p )
		self.DefaultButton:SetTall(20)
		self.DefaultButton:Dock(BOTTOM)
		self.DefaultButton:DockMargin(0, self:GetPadding() * 2, 0 ,self:GetPadding())
		self.DefaultButton:SetIcon("icon16/shield.png")
		self.DefaultButton:SetText("Set As Initial Preset")

		self.DefaultButton.DoClick = function()
			if (table.IsEmpty(self.Preset)) then
				return
			end

			if (self.LastListValue == "server_preset.json") then
				MediaPlayer.CreateWarningBox("Error", "server_preset.json is the same as server.json and only exists on the server.", 4)
				return
			end

			if (self.LastListValue == "server.json") then
				MediaPlayer.CreateWarningBox("Error", "server.json is the same as server_preset.json and only exists on the client.", 4)
				return
			end

			MediaPlayer.SendPresetToServer(self.Preset)
			MediaPlayer.RefreshDefaultPreset()
			MediaPlayer.InstantiatePanels(true)
			MediaPlayer.CreateSuccessBox("Success", "Initial preset uploaded and set successfully applied!", 4)
		end
	end

	if (IsValid(self.CopyButton)) then self.CopyButton:Remove() end

	self.CopyButton = vgui.Create("DButton", p )
	self.CopyButton:SetTall(15)
	self.CopyButton:Dock(BOTTOM)
	self.CopyButton:DockMargin(0,self:GetPadding() * 2,0,0)
	self.CopyButton:SetText("Copy Preset")

	if (IsValid(self.SaveButton)) then self.SaveButton:Remove() end

	self.SaveButton = vgui.Create("DButton", p )
	self.SaveButton:SetTall(30)
	self.SaveButton:Dock(BOTTOM)
	self.SaveButton:DockMargin(0,self:GetPadding(),0,0)
	self.SaveButton:SetText("Save Preset")

	if (self:IsPresetLocked()) then
		self.SaveButton:SetDisabled(true)
	end

	self.SaveButton.DoClick = function(s)
		MediaPlayer.SavePreset(self.LastListValue, self.Preset)
		MediaPlayer.CreateSuccessBox("Success", self.LastListValue .. " has been saved successfully!")
	end

	self.HasEdited = false
end

function panel:IsPresetLocked()
	return self.Preset != nil and self.Preset.Locked != nil and self.Preset.Locked == true
end

vgui.Register("MediaPlayer.SettingPresets", panel, "MediaPlayer.BasePanel")