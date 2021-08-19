local panel = {}

panel.Name = "settings"

function panel:Init()
	self:BaseInit()

	self.Presets = {}

	self:SetDockPadding()
	self:IgnoreReposition()
	self:SetIgnoreRescaling(true, true )

	self.Paint = function() end

	self:Dock(FILL)

	self.ListView = vgui.Create("DListView", self )
	self.ListView:Dock(LEFT)
	self.ListView:SetWide( ( self:GetWidth() / 3 ) - ( self:GetPadding() * 2 ) )
	self.ListView:SetTall( self:GetHeight() )
	self.ListView:AddColumn("Presets")


	self:SetDockMargin(self.ListView)

	self.LastListValue = nil

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
			self.Preset = self.Presets[k]
			self:FillPresetEditor()
			self.PresetEditor:Show()
		end
	end

	local help = vgui.Create("DButton", self.ListView )
	help:SetTall(15)
	help:Dock(BOTTOM)
	help:SetText("Help")
	self:SetDockMargin(help)

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
	label_title:SetText("Preset Title (must be unique)")

	self.PresetTitle = vgui.Create("DTextEntry", self.PresetCreator)
	self.PresetTitle:Dock(TOP)
	self.PresetTitle:SetPlaceholderText("untitled")

	local label_author = vgui.Create("DLabel", self.PresetCreator)
	label_author:Dock(TOP)
	label_author:SetText("Author")

	self.PresetAuthor = vgui.Create("DTextEntry", self.PresetCreator)
	self.PresetAuthor:Dock(TOP)
	self.PresetAuthor:DockMargin( 0, 0, 0, self:GetPadding() )
	self.PresetAuthor:SetValue( MEDIA.LocalPlayer:Name() )

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

		if (!self:CreatePreset(self.PresetAuthor:GetValue(), self.PresetTitle:GetValue())) then
			MEDIA.CreateWarningBox("Oh no!","Something went wrong making that preset! make sure the title has no spaces and only includes underscores as well as plain text, no extensions!")
		end
	end
end

function panel:CreatePreset(title, autor)
	return false
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
			self.PresetPreview:DisplaySettings(k, self.Preset.Settings[k])
			self.LastValue = k
		end

	end

	if (self.Preset.Settings != nil and !table.IsEmpty(self.Preset.Settings)) then
		for k,v in pairs(self.Preset.Settings) do
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

	for k,v in pairs(MEDIA.Settings) do
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

	if (IsValid(self.AddButton)) then self.AddButton:Remove() end

	self.AddButton = vgui.Create("DButton", p )
	self.AddButton:SetTall(30)
	self.AddButton:Dock(TOP)
	self.AddButton:SetDisabled(true)
	self.AddButton:DockMargin(0,self:GetPadding(),0,self:GetPadding() * 4)
	self.AddButton:SetText("Add Setting")

	self.AddButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end

		local sel = self.ComboBox:GetSelected()

		if ( sel != nil and sel != "..." ) then

			local tab = table.Copy(MEDIA.GetSetting(sel))
			self.Preset.Settings[sel] = tab.Value
			self.HasEdited = true
			self:FillPresetEditor()
		end
	end

	self.RemoveButton = vgui.Create("DButton", p )
	self.RemoveButton:SetTall(15)
	self.RemoveButton:Dock(TOP)
	self.RemoveButton:SetDisabled(true)
	self.RemoveButton:DockMargin(0,self:GetPadding(),0,0)
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

	self.UpdateButton = vgui.Create("DButton", p )
	self.UpdateButton:SetTall(15)
	self.UpdateButton:Dock(TOP)
	self.UpdateButton:SetDisabled(true)
	self.UpdateButton:DockMargin(0,self:GetPadding(),0,0)
	self.UpdateButton:SetText("Update Setting To Current Setting")

	self.UpdateButton.DoClick = function()

		if (self:IsPresetLocked()) then
			return
		end


		local sel = self.LastValue or nil

		if ( sel != nil and sel != "..." ) then

			local tab = table.Copy(MEDIA.GetSetting(sel))
			self.Preset.Settings[sel] = tab.Value
			self.HasEdited = true
			self:FillPresetEditor()
		end
	end

	if (IsValid(self.PresetPreview)) then self.PresetPreview:Remove() end

	self.PresetPreview = vgui.Create("MEDIA.PresetPreview", p )
	self.PresetPreview:Dock(TOP)
	self.PresetPreview:DockMargin(0, self:GetPadding() * 2, 0, 0)
	self.PresetPreview:SetTall(50)

	self.LoadButton = vgui.Create("DButton", p )
	self.LoadButton:SetTall(15)
	self.LoadButton:Dock(BOTTOM)
	self.LoadButton:DockMargin(0,self:GetPadding(),0,0)
	self.LoadButton:SetText("Apply Preset")

	if (MEDIA.LocalPlayer:IsAdmin() ) then
		self.DefaultButton = vgui.Create("DButton", p )
		self.DefaultButton:SetTall(15)
		self.DefaultButton:Dock(BOTTOM)
		self.DefaultButton:DockMargin(0,self:GetPadding(),0,0)
		self.DefaultButton:SetIcon("icon16/shield.png")
		self.DefaultButton:SetText("Save & Set As Initial Preset")
	end

	self.SaveButton = vgui.Create("DButton", p )
	self.SaveButton:SetTall(15)
	self.SaveButton:Dock(BOTTOM)
	self.SaveButton:DockMargin(0,self:GetPadding(),0,0)
	self.SaveButton:SetText("Save Preset")

	if (self:IsPresetLocked() or self.HasEdited == nil or self.HasEdited == false ) then
		self.SaveButton:SetDisabled(true)
	end

	self.HasEdited = false
end

function panel:IsPresetLocked()
	return self.Preset != nil and self.Preset.Locked != nil and self.Preset.Locked == true
end

vgui.Register("MEDIA.SettingPresets", panel, "MEDIA.BasePanel")