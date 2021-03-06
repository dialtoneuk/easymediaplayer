local panel = {}
panel.Name = "settings"

function panel:Init()
    self:BaseInit({
        DontResize = {
            Width = true,
            Height = true,
        },
        Declare = {
            Rows = 1
        },
        Locked = true
    })
end

function panel:Paint(p)
    --nothing``
end

function panel:MyThink()
    if (IsValid(self.Properties) and IsValid(self.Parent)) then
        self:SetTall(math.max(self.Settings.Options.Value.PropertyMinHeight or 56, math.min((self.Parent:GetTall() / 4) - (self:GetPadding() * 2), (self.Rows or 1) * (self.Settings.Options.Value.PropertyRowSpacing or 28))))
    end
end

--takes the key of the setting inside MEDIA.Settings and then the alue,
function panel:DisplaySettings(k, v, parent)
    if not (LydsPlayer.HasSetting(k)) then
        self.Parent.Preset.Settings[k] = nil

        return
    end

    self.Parent = parent
    v = self.Parent.Preset.Settings[k]

    if (IsValid(self.Properties)) then
        self.Properties:Remove()
    end

    self.Rows = 0
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
                if (self.Parent:IsPresetLocked()) then
                    LydsPlayer.CreateWarningBox("Warning", "This preset is locked and you cannot make any changes to it unless you copy it.")

                    return
                end

                d = string.Explode(" ", d)

                if (key ~= nil) then
                    self.Parent.Preset.Settings[k][key] = LydsPlayer.VarToColour(d)
                    row:SetValue(self.Parent.Preset.Settings[k][key])
                else
                    self.Parent.Preset.Settings[k] = LydsPlayer.VarToColour(d)
                    row:SetValue(self.Parent.Preset.Settings[k])
                end
            end
        else
            local row = self.Properties:CreateRow(key or k, typs[typ])
            local _min = 0
            local _max

            if (typs[typ] == "Integer" or typs[typ] == "Float") then
                if (self.Parent:IsPresetLocked()) then
                    _min = data
                    _max = data
                else
                    _max = data * 10
                end

                local map = {
                    ["Integer"] = "Int",
                    ["Float"] = "Float"
                }

                row:Setup(map[typs[typ]], {
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
                if (self.Parent:IsPresetLocked()) then
                    LydsPlayer.CreateWarningBox("Warning", "This preset is locked and you cannot make any changes to it unless you copy it.")

                    return
                end

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

    local setting = LydsPlayer.GetSetting(k)
    self.Rows = (self.Rows or 1) + 1

    if (setting.Type == LydsPlayer.Type.TABLE) then
        for key, value in pairs(v) do
            local typ
            self.Rows = (self.Rows or 1) + 1

            if (setting.DefValue.__unpack ~= nil and string.sub(key, 1, 2) ~= "__") then
                v[key] = setting.DefValue.__unpack(self.Parent.Preset.Settings[k], key, v[key])
            end

            if (string.sub(key, 1, 2) == "__") then continue end

            if (type(v[key]) == "boolean") then
                typ = LydsPlayer.Type.BOOL
            elseif (type(v[key]) == "number") then
                typ = LydsPlayer.Type.INT
            else
                typ = LydsPlayer.Type.BOOL
            end

            create(v[key], key, typ)
        end
    else
        create(v, nil, setting.Type)
    end
end

vgui.Register("LydsPlayer.PresetPreview", panel, "LydsPlayer.BasePanel")