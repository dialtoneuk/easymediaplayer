local panel = {}
panel.Name = "settings"

panel.DefaultSettings = {
    Panels = {"warning", "success", "base", "settings", "player", "playlist", "admin", "vote", "search"},
    Keys = {"colours", "size", "position", "options", "invert_position", "auto_resize", "resize_scale"}
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
    self.ListView = vgui.Create("DListView", self)
    self.ListView:Dock(LEFT)
    self.ListView:SetWide((self:GetWidth() / 3) - (self:GetPadding() * 2))
    self.ListView:SetTall(self:GetHeight())
    self.ListView:AddColumn("Presets")
    self:SetDockMargin(self.ListView)

    self.ListView.OnRowSelected = function(p, index, row)
        local k = row:GetValue(1)

        if (self.PresetCreator:IsVisible()) then
            self.PresetCreator:Hide()
            self:CreateAddButton()
        end

        if (self.LastListValue == k) then
            self.PresetEditor:Show()

            return
        end

        if (not self.Presets[k]) then
            error(k .. "not set in presets")
        else
            self.LastListValue = k
            if (k == "server_preset.json" and not LydsPlayer.LocalPlayer:IsAdmin()) then return end
            self.Preset = self.Presets[k]
            self:FillPresetEditor()
            self.PresetEditor:Show()
        end
    end

    --help button
    local refresh = vgui.Create("DButton", self.ListView)
    refresh:Dock(BOTTOM)
    refresh:SetTall(30)
    refresh:SetText("Refresh List")
    refresh:SetIcon("icon16/arrow_refresh.png")

    refresh.DoClick = function(s)
        self.ListView:Clear()
        self:GetPresets()
    end

    self:SetDockMargin(refresh)
    --creates add button
    self:CreateAddButton()
    self.PresetEditor = vgui.Create("DPanel", self)
    self.PresetEditor:Dock(RIGHT)
    self.PresetEditor:SetTall(self:GetHeight())
    self.PresetEditor:SetWide(self.ListView:GetWide() * 2 - (self:GetPadding() * 2))
    self.PresetEditor:Hide()
    self.PresetEditor.Paint = function() end
    self:SetDockMargin(self.PresetEditor)
    self.PresetCreator = vgui.Create("DPanel", self)
    self.PresetCreator:Dock(RIGHT)
    self.PresetCreator:SetTall(self:GetHeight())
    self.PresetCreator:SetWide(self.ListView:GetWide() * 2 - (self:GetPadding() * 2))
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
    add:SetTall(30)
    add:SetText("New Preset")
    add:SetIcon("icon16/page_add.png")

    add.DoClick = function(s)
        s:Remove()
        self.PresetEditor:Hide()

        if (not IsValid(self.PresetTitle)) then
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
    --title
    self.PresetTitle = vgui.Create("DTextEntry", self.PresetCreator)
    self.PresetTitle:Dock(TOP)
    self.PresetTitle:SetPlaceholderText("untitled")
    self.PresetTitle:SetTall(40)
    --label
    local label_author = vgui.Create("DLabel", self.PresetCreator)
    label_author:Dock(TOP)
    label_author:SetText("Author")
    --
    self.PresetAuthor = vgui.Create("DTextEntry", self.PresetCreator)
    self.PresetAuthor:Dock(TOP)
    self.PresetAuthor:DockMargin(0, 0, 0, self:GetPadding())
    self.PresetAuthor:SetValue(LydsPlayer.LocalPlayer:Name())
    self.PresetAuthor:SetTall(40)
    --checkbox
    self.Checkbox = vgui.Create("DCheckBoxLabel", self.PresetCreator)
    self.Checkbox:Dock(TOP)
    self.Checkbox:SetText("Initiate with some default settings such as the size, position and colour of all elements")
    self.Checkbox:SetValue(true)
    self.Checkbox:SizeToContents()
    self.Checkbox:DockMargin(0, 0, 0, self:GetPadding())
    local add = vgui.Create("DButton", self.PresetCreator)
    add:Dock(TOP)
    add:SetTall(30)
    add:DockMargin(0, self:GetPadding(), 0, 0)
    add:SetText("Create Preset")
    add:SetIcon("icon16/page_add.png")

    add.DoClick = function(s)
        local result = self:CreatePreset(self.PresetTitle:GetValue(), self.PresetAuthor:GetValue(), self.Checkbox:GetChecked())

        if (not result) then
            LydsPlayer.CreateWarningBox("Unsuccessful", "Please make sure the title is not taken by something else and it also doesn't contain any special characters. Please change: " .. self.PresetTitle:GetValue())
        else
            self.ListView:AddLine(result)
            self.PresetCreator:Hide()
            self:CreateAddButton()
        end
    end

    local cancel = vgui.Create("DButton", self.PresetCreator)
    cancel:Dock(TOP)
    cancel:SetTall(30)
    cancel:DockMargin(0, self:GetPadding() * 2, 0, 0)
    cancel:SetText("Cancel")
    cancel:SetIcon("icon16/stop.png")

    cancel.DoClick = function(s)
        self.PresetCreator:Hide()
        self:CreateAddButton()
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

    if (author == "" or string.len(author) > 24) then
        author = LydsPlayer.LocalPlayer:GetName()
    end

    if (title == "" or title == "_" or string.len(title) > 52) then return false end
    --any special chars
    if (string.match(title, "[\\/:;*£-+`=$?\".@#~+^,()!{}<>|]")) then return false end
    local settings = {}

    if (add_default) then
        for k, v in pairs(self.DefaultSettings.Panels) do
            for _, setting in pairs(self.DefaultSettings.Keys) do
                settings[v .. "_" .. setting] = LydsPlayer.GetSetting(v .. "_" .. setting).Value
            end
        end

        --some more default settings
        settings["player_display_video"] = LydsPlayer.GetSetting("player_display_video").Value
        settings["player_show_in_context"] = LydsPlayer.GetSetting("player_show_in_context").Value
        settings["player_show_current_video"] = LydsPlayer.GetSetting("player_show_current_video").Value
        settings["player_show_current_video_constantly"] = LydsPlayer.GetSetting("player_show_current_video_constantly").Value
        settings["player_show_in_scoreboard"] = LydsPlayer.GetSetting("player_show_in_scoreboard").Value
        settings["search_column_count"] = LydsPlayer.GetSetting("search_column_count").Value
    end

    local preset = {
        Author = author,
        Locked = false,
        Description = "User created preset",
        Version = LydsPlayer.Version,
        Settings = settings
    }

    if (file.Exists("lyds/presets/" .. title .. ".json", "DATA")) then return false end
    LydsPlayer.SavePreset(title, table.Copy(preset))
    self.Presets[title .. ".json"] = table.Copy(preset)

    return title .. ".json"
end

function panel:GetPresets()
    if (not file.IsDir("lyds/presets", "DATA")) then
        file.CreateDir("lyds/presets")

        return
    end

    local files = file.Find("lyds/presets/*.json", "DATA")

    if (not table.IsEmpty(files)) then
        for k, v in pairs(files) do
            local result = util.JSONToTable(file.Read("lyds/presets/" .. v, "DATA"))

            if (result == nil or table.IsEmpty(result) or result.Settings == nil) then
                warning("there was an issue parsing the preset file called ", v)
                continue
            end

            self.Presets[v] = result
        end

        if (not table.IsEmpty(self.Presets)) then
            for k, v in pairs(self.Presets) do
                self.ListView:AddLine(k)
            end
        end
    end
end

function panel:FillPresetEditor()
    if (self.Preset == nil or table.IsEmpty(self.Preset)) then return end

    if (IsValid(self.CurrentPreset)) then
        self.CurrentPreset:Remove()
    end

    self.CurrentPreset = vgui.Create("DPanel", self.PresetEditor)
    self.CurrentPreset:Dock(FILL)
    self.CurrentPreset:SetPaintBackgroundEnabled(false)
    self:SetDockPadding(self.CurrentPreset)
    self:SetDockMargin(self.CurrentPreset)
    local listview = vgui.Create("DListView", self.CurrentPreset)
    listview:Dock(LEFT)
    listview:SetWide(math.floor(self.PresetEditor:GetWide() * 0.40) - (self:GetPadding() * 2))
    listview:AddColumn("Included Settings")
    self.LastValue = nil

    listview.OnRowSelected = function(p, index, row)
        local k = row:GetValue(1)

        if (not self:IsPresetLocked()) then
            self.RemoveButton:SetDisabled(false)
            self.UpdateButton:SetDisabled(false)

            if (IsValid(self.SaveButton)) then
                self.SaveButton:SetDisabled(false)
            end
        end

        if (IsValid(self.PresetPreview) and self.LastValue ~= k) then
            self.PresetPreview:DisplaySettings(k, self.Preset.Settings[k], self)
            self.LastValue = k
        end
    end

    if (self.Preset.Settings ~= nil and not table.IsEmpty(self.Preset.Settings)) then
        for k, v in pairs(self.Preset.Settings) do
            if (not LydsPlayer.HasSetting(k)) then
                self.Preset.Settings[k] = nil
                continue
            end

            if (k ~= nil) then
                listview:AddLine(k)
            end
        end
    end

    --container
    local p = vgui.Create("DPanel", self.CurrentPreset)
    p:Dock(RIGHT)
    p:SetWide(math.floor(self.PresetEditor:GetWide() * 0.60) - (self:GetPadding() * 2))
    p.Paint = function() end
    self:SetDockPadding(p)

    if (IsValid(self.ComboBox)) then
        self.ComboBox:Remove()
    end

    self.ComboBox = vgui.Create("DComboBox", p)
    self.ComboBox:SetTall(30)
    self.ComboBox:Dock(TOP)
    self.ComboBox:SetValue("...")

    for k, v in pairs(LydsPlayer.Settings) do
        self.ComboBox:AddChoice(k)
    end

    self.ComboBox.OnSelect = function(s, index, value)
        if (self:IsPresetLocked()) then return end
        self.AddButton:SetDisabled(false)
    end

    if (self:IsPresetLocked()) then
        self.ComboBox:SetDisabled(true)
    end

    if (IsValid(self.AddButton)) then
        self.AddButton:Remove()
    end

    self.AddButton = vgui.Create("DButton", p)
    self.AddButton:SetTall(30)
    self.AddButton:Dock(TOP)
    self.AddButton:SetDisabled(true)
    self.AddButton:DockMargin(0, self:GetPadding() * 2, 0, self:GetPadding())
    self.AddButton:SetText("Add Setting")
    self.AddButton:SetIcon("icon16/add.png")

    self.AddButton.DoClick = function()
        if (self:IsPresetLocked()) then return end
        local sel = self.ComboBox:GetSelected()

        if (sel ~= nil and sel ~= "...") then
            local tab = table.Copy(LydsPlayer.GetSetting(sel))
            self.Preset.Settings[sel] = tab.Value
            self.HasEdited = true
            self:FillPresetEditor()
        end
    end

    if (IsValid(self.InspectButton)) then
        self.InspectButton:Remove()
    end

    self.InspectButton = vgui.Create("DButton", p)
    self.InspectButton:SetTall(20)
    self.InspectButton:Dock(TOP)
    self.InspectButton:DockMargin(0, 0, 0, self:GetPadding() * 2)
    self.InspectButton:SetText("Inspect Preset")
    self.InspectButton:SetIcon("icon16/eye.png")

    self.InspectButton.DoClick = function()
        --recreate it
        LydsPlayer.ReinstantiatePanel("PresetPreview")
        local pan = LydsPlayer.GetPanel("PresetPreview")
        pan:SetPreview(self:GetPresetPreview())
        pan:MakePopup()
        pan:Show()
    end

    if (IsValid(self.TryoutButton)) then
        self.TryoutButton:Remove()
    end

    self.TryoutButton = vgui.Create("DButton", p)
    self.TryoutButton:SetTall(20)
    self.TryoutButton:Dock(TOP)
    self.TryoutButton:DockMargin(0, 0, 0, self:GetPadding())
    self.TryoutButton:SetText("Test Preset")
    self.TryoutButton:SetIcon("icon16/flag_pink.png")

    if (IsValid(self.VersionText)) then
        self.VersionText:Remove()
    end

    self.VersionText = vgui.Create("DLabel", p)
    self.VersionText:SetTall(20)
    self.VersionText:Dock(TOP)
    self.VersionText:SetFont("BigText")
    self.VersionText:DockMargin(0, self:GetPadding(), 0, 0)
    local versionText = "built w/ ver " .. (self.Preset.Version or "?.?") .. " (yours " .. LydsPlayer.Version .. ")"

    if (self.Preset.Version == LydsPlayer.Version) then
        self.VersionText:SetTextColor(LydsPlayer.Colours.Green)
    else
        if (self.Preset.Version ~= nil and LydsPlayer.Version < 1.0 and self.Preset.Version > LydsPlayer.Version - 0.5) then
            self.VersionText:SetTextColor(LydsPlayer.Colours.Orange)
            versionText = versionText .. " [Unsupported]"
        else
            self.VersionText:SetTextColor(LydsPlayer.Colours.Red)
            versionText = versionText .. " [Unadvised]"
        end
    end

    self.VersionText:SetText(versionText)

    if (IsValid(self.AuthorText)) then
        self.AuthorText:Remove()
    end

    self.AuthorText = vgui.Create("DLabel", p)
    self.AuthorText:SetTall(15)
    self.AuthorText:Dock(TOP)
    self.AuthorText:DockMargin(0, self:GetPadding(), 0, 0)
    self.AuthorText:SetText("Author: " .. (self.Preset.Author or "Unknown Author?"))
    self.AuthorText:SetTextColor(LydsPlayer.Colours.Black)

    if (IsValid(self.RemoveButton)) then
        self.RemoveButton:Remove()
    end

    self.RemoveButton = vgui.Create("DButton", p)
    self.RemoveButton:SetTall(20)
    self.RemoveButton:Dock(TOP)
    self.RemoveButton:SetDisabled(true)
    self.RemoveButton:DockMargin(0, self:GetPadding() * 2, 0, 0)
    self.RemoveButton:SetText("Remove Setting")
    self.RemoveButton:SetIcon("icon16/delete.png")
    self.RemoveButton:SetPaintBackground(false)

    self.RemoveButton.Paint = function()
        draw.RoundedBox(5, 0, 0, self.RemoveButton:GetWide(), self.RemoveButton:GetTall(), LydsPlayer.ComputedColours.FadedRed)
    end

    self.RemoveButton.DoClick = function()
        if (self:IsPresetLocked()) then return end
        local sel = self.LastValue or nil

        LydsPlayer.CreateOptionBox("Are you sure?", "Are you sure you want to delete " .. sel .. "?", function(result)
            if (not result) then return end

            if (sel ~= nil) then
                self.Preset.Settings[sel] = nil
                self:FillPresetEditor()
                self.HasEdited = true
            end
        end)
    end

    if (IsValid(self.UpdateButton)) then
        self.UpdateButton:Remove()
    end

    self.UpdateButton = vgui.Create("DButton", p)
    self.UpdateButton:SetTall(20)
    self.UpdateButton:Dock(TOP)
    self.UpdateButton:SetDisabled(true)
    self.UpdateButton:DockMargin(0, self:GetPadding(), 0, 0)
    self.UpdateButton:SetText("Set Value To Current Setting")

    self.UpdateButton.DoClick = function()
        if (self:IsPresetLocked()) then return end
        local sel = self.LastValue or nil

        if (sel ~= nil and sel ~= "...") then
            local tab = table.Copy(LydsPlayer.GetSetting(sel))
            self.Preset.Settings[sel] = tab.Value
            self.HasEdited = true
            self:FillPresetEditor()
            LydsPlayer.CreateSuccessBox("Success", sel .. " have been matched with the value of your current setting")
        end
    end

    if (IsValid(self.PresetPreview)) then
        self.PresetPreview:Remove()
    end

    self.PresetPreview = vgui.Create("LydsPlayer.PresetPreview", p)
    self.PresetPreview:Dock(TOP)
    self.PresetPreview:DockMargin(0, self:GetPadding(), 0, 0)
    self.PresetPreview:SetTall(self:GetTall() / 4)

    if (IsValid(self.UpdateAllButton)) then
        self.UpdateAllButton:Remove()
    end

    self.UpdateAllButton = vgui.Create("DButton", p)
    self.UpdateAllButton:SetTall(20)
    self.UpdateAllButton:Dock(TOP)
    self.UpdateAllButton:SetDisabled(true)
    self.UpdateAllButton:SetText("Match Properties With Yours")
    self.UpdateAllButton:SetIcon("icon16/wand.png")

    self.UpdateAllButton.DoClick = function()
        if (self:IsPresetLocked()) then return end
        self.HasEdited = true

        for k, v in pairs(self.Preset.Settings) do
            local tab = table.Copy(LydsPlayer.GetSetting(k))
            self.Preset.Settings[k] = tab.Value
            self:FillPresetEditor()
            LydsPlayer.CreateSuccessBox("Success", "All properties have been matched with the value of your current settings.")
        end
    end

    if (not self:IsPresetLocked()) then
        self.UpdateAllButton:SetDisabled(false)
    end

    if (IsValid(self.SaveButton)) then
        self.SaveButton:Remove()
    end

    self.SaveButton = vgui.Create("DButton", p)
    self.SaveButton:SetTall(40)
    self.SaveButton:Dock(BOTTOM)
    self.SaveButton:DockMargin(0, self:GetPadding(), 0, 0)
    self.SaveButton:SetText("Save Preset")
    self.SaveButton:SetIcon("icon16/disk.png")

    if (self:IsPresetLocked()) then
        self.SaveButton:SetDisabled(true)
    end

    self.SaveButton.DoClick = function(s)
        LydsPlayer.SavePreset(self.LastListValue, self.Preset)
        LydsPlayer.CreateSuccessBox("Success", self.LastListValue .. " has been saved successfully!")
    end

    if (IsValid(self.LoadButton)) then
        self.LoadButton:Remove()
    end

    self.LoadButton = vgui.Create("DButton", p)
    self.LoadButton:SetTall(40)
    self.LoadButton:Dock(BOTTOM)
    self.LoadButton:DockMargin(0, self:GetPadding(), 0, 0)
    self.LoadButton:SetText("Apply Preset")
    self.LoadButton:SetIcon("icon16/page_lightning.png")

    self.LoadButton.DoClick = function()
        LydsPlayer.ApplyPreset(self.Preset)
        RunConsoleCommand("media_create_cl")
        LydsPlayer.CreateSuccessBox("Success", "Preset " .. self.LastListValue .. " successfully applied")
        RunConsoleCommand("settings")
    end

    if (LydsPlayer.LocalPlayer:IsAdmin()) then
        if (IsValid(self.DefaultButton)) then
            self.DefaultButton:Remove()
        end

        self.DefaultButton = vgui.Create("DButton", p)
        self.DefaultButton:SetTall(20)
        self.DefaultButton:Dock(BOTTOM)
        self.DefaultButton:DockMargin(0, self:GetPadding(), 0, self:GetPadding())
        self.DefaultButton:SetIcon("icon16/shield.png")
        self.DefaultButton:SetText("Set As Global Preset")

        self.DefaultButton.DoClick = function()
            if (table.IsEmpty(self.Preset)) then return end

            if (self.LastListValue == "server_preset.json") then
                LydsPlayer.CreateWarningBox("Error", "This preset is already set as the global preset.", 4)

                return
            end

            if (self.LastListValue == "server.json") then
                LydsPlayer.CreateWarningBox("Error", "server.json is the same as server_preset.json and only exists on the client.", 4)

                return
            end

            LydsPlayer.SendPresetToServer(self.Preset)
            LydsPlayer.RefreshDefaultPreset()
            LydsPlayer.InstantiatePanels(true)
            LydsPlayer.CreateSuccessBox("Success", "Initial preset uploaded and set successfully applied!", 4)
        end
    end

    if (IsValid(self.DeleteButton)) then
        self.DeleteButton:Remove()
    end

    self.DeleteButton = vgui.Create("DButton", p)
    self.DeleteButton:SetTall(20)
    self.DeleteButton:Dock(BOTTOM)
    self.DeleteButton:DockMargin(0, self:GetPadding(), 0, 0)
    self.DeleteButton:SetText("Delete Preset")
    self.DeleteButton:SetIcon("icon16/delete.png")
    self.DeleteButton:SetPaintBackground(false)

    self.DeleteButton.Paint = function()
        draw.RoundedBox(5, 0, 0, self.DeleteButton:GetWide(), self.DeleteButton:GetTall(), LydsPlayer.ComputedColours.FadedRed)
    end

    if (self:IsPresetLocked()) then
        self.DeleteButton:SetDisabled(true)
    end

    self.DeleteButton.DoClick = function(s)
        LydsPlayer.CreateOptionBox("Remove Preset", "Are you sure you want to remove " .. self.LastListValue .. "? This cannot be undone!", function(res)
            if (res) then
                self.Presets[self.LastListValue] = nil
                file.Delete("lyds/presets/" .. self.LastListValue)
                self.ListView:Clear()
                self:GetPresets()
            end
        end)
    end

    if (IsValid(self.CopyButton)) then
        self.CopyButton:Remove()
    end

    self.CopyButton = vgui.Create("DButton", p)
    self.CopyButton:SetTall(20)
    self.CopyButton:Dock(BOTTOM)
    self.CopyButton:DockMargin(0, self:GetPadding(), 0, 0)
    self.CopyButton:SetText("Copy Preset")
    self.CopyButton:SetIcon("icon16/page_copy.png")

    self.CopyButton.DoClick = function(s)
        local val = string.Replace(self.LastListValue, ".json", "")
        local tab = table.Copy(self.Preset)
        tab.Locked = false
        tab.Version = LydsPlayer.Version
        tab.Author = LydsPlayer.LocalPlayer:GetName()

        if (file.Exists("lyds/presets/" .. val .. ".json", "DATA")) then
            val = val .. "-" .. math.random(1, 1000)
        end

        val = val .. ".json"

        if (file.Exists("lyds/presets/" .. val, "DATA")) then
            error("cannot generate unique file name")

            return
        end

        LydsPlayer.SavePreset(val, tab)
        LydsPlayer.CreateSuccessBox("Success", self.LastListValue .. " has been successfully copied and named " .. val .. "!")
        self.Presets[val] = tab
        self.ListView:AddLine(val)
    end

    self.HasEdited = false
end

function panel:GetPresetPreview()
    if (self.Preset == nil) then return {} end
    local tab = {}

    for k, v in pairs(self.DefaultSettings.Panels) do
        if (self.Preset.Settings[v .. "_colours"] ~= nil) then
            tab[v .. "_colours"] = table.Copy(self.Preset.Settings[v .. "_colours"])
        end

        if (self.Preset.Settings[v .. "_size"] ~= nil) then
            tab[v .. "_size"] = table.Copy(self.Preset.Settings[v .. "_size"])
        end

        if (self.Preset.Settings[v .. "_position"] ~= nil) then
            tab[v .. "_position"] = table.Copy(self.Preset.Settings[v .. "_position"])
        end

        if (self.Preset.Settings[v .. "_resize_scale"] ~= nil) then
            tab[v .. "_resize_scale"] = self.Preset.Settings[v .. "_resize_scale"]
        end

        if (self.Preset.Settings[v .. "_invert_position"] ~= nil) then
            tab[v .. "_invert_position"] = self.Preset.Settings[v .. "_invert_position"]
        end

        if (self.Preset.Settings[v .. "_centered"] ~= nil) then
            tab[v .. "_centered"] = self.Preset.Settings[v .. "_centered"]
        end
    end

    return tab
end

function panel:IsPresetLocked()
    return self.Preset ~= nil and self.Preset.Locked ~= nil and self.Preset.Locked == true
end

vgui.Register("LydsPlayer.SettingPresets", panel, "LydsPlayer.BasePanel")