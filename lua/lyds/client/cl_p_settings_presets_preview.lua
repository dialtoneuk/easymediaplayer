local panel = {}
panel.Name = "settings"

panel.Resize = {
    Width = false,
    Height = false
}

function panel:Init()
    self:BaseInit()
    self:SetIgnoreRescaling(true, true)
    self:IgnoreReposition()
    self.Paint = function() end
end

--takes the key of the setting inside MEDIA.Settings and then the alue,
function panel:DisplaySettings(k, v, parent)
    self.Parent = parent
    v = self.Parent.Preset.Settings[k]

    if (IsValid(self.Properties)) then
        self.Properties:Remove()
    end

    if (self.Parent:IsPresetLocked()) then

        if (IsValid(self.LabelTitle)) then self.LabelTitle:Remove() end

        self.LabelTitle = vgui.Create("DLabel", self)
        self.LabelTitle:Dock(TOP)
        self.LabelTitle:SetText("Unmodifiable")
        self.LabelTitle:SetTextColor(MediaPlayer.Colours.Black)
    end

    self.Properties = vgui.Create("DProperties", self)
    self:SetDockMargin(self.Properties)
    self.Properties:Dock(FILL)

    local typs = {
        bool = "Boolean",
        int = "Integer",
        float = "Float",
        string = "Generic"
    }

    local create = function(data, key, typ)
        key = key or nil

        if (IsColor(data)) then
            local row = self.Properties:CreateRow(key, "VectorColor")
            row:Setup("VectorColor")

            if (key ~= nil) then
                row:SetValue(self.Parent.Preset.Settings[k][key])
            else
                row:SetValue(self.Parent.Preset.Settings[k])
            end

            row.DataChanged = function(s, d)
                if (self.Parent:IsPresetLocked()) then return end
                d = string.Explode(" ", d)

                if (key ~= nil) then
                    self.Parent.Preset.Settings[k][key] = MediaPlayer.VarToColour(d)
                    row:SetValue(self.Parent.Preset.Settings[k][key])
                else
                    self.Parent.Preset.Settings[k] = MediaPlayer.VarToColour(d)
                    row:SetValue(self.Parent.Preset.Settings[k])
                end
            end
        else
            local row = self.Properties:CreateRow(key or k, typs[typ])
            local _min = 0
            local _max

            if (typs[typ] == "Integer") then
                if (self.Parent:IsPresetLocked()) then
                    _min = data
                    _max = data
                else
                    _max = data * 10
                end

                row:Setup("Int", {
                    min = _min,
                    max = _max
                })
            else
                row:Setup(typs[typ])
            end

            if (key ~= nil) then
                row:SetValue(self.Parent.Preset.Settings[k][key])
            else
                row:SetValue(self.Parent.Preset.Settings[k])
            end

            row.DataChanged = function(s, d)
                if (key ~= nil) then
                    self.Parent.Preset.Settings[k][key] = d
                    row:SetValue(self.Parent.Preset.Settings[k][key])
                else
                    self.Parent.Preset.Settings[k] = d
                    row:SetValue(self.Parent.Preset.Settings[k])
                end
            end
        end
    end

    local setting = MediaPlayer.GetSetting(k)

    if (setting.Type == MediaPlayer.Types.TABLE) then
        for key, value in pairs(v) do
            local typ

            if (setting.DefValue.__unpack ~= nil and string.sub(key, 1, 2) ~= "__") then
                v[key] = setting.DefValue.__unpack(self.Parent.Preset.Settings[k], key, v[key])
            end

            if (string.sub(key, 1, 2) == "__") then continue end

            if (type(v[key]) == "boolean") then
                typ = MediaPlayer.Types.BOOL
            elseif (type(v[key]) == "number") then
                typ = MediaPlayer.Types.INT
            else
                typ = MediaPlayer.Types.BOOL
            end

            create(v[key], key, typ)
        end
    else
        create(v, nil, setting.Type)
    end
end

vgui.Register("MediaPlayer.PresetPreview", panel, "MediaPlayer.BasePanel")