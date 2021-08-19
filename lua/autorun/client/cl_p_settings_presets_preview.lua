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

function panel:DisplaySettings(k, v)

    if (IsValid(self.Properties)) then self.Properties:Remove() end

    self.Properties = vgui.Create("DProperties", self )
    self:SetDockMargin(self.Properties)
    self.Properties:Dock(FILL)

    local typs = {
        bool = "Boolean",
        int = "Integer",
        float = "Float",
        string = "Generic"
    }

    local create = function(data, key, typ)
        local row
        key = key .. " (unmodifiable)"

        if (IsColor(data)) then
            row = self.Properties:CreateRow(key, "VectorColor")
            row:Setup("VectorColor")
            row:SetValue(data)
        else
            row = self.Properties:CreateRow(key, typs[typ])

            if (typs[typ] == "Integer" ) then
                row:Setup("Int", { min = data, max = data})
            else
                row:Setup(typs[typ])
            end

            row:SetValue(data)
        end
    end

    local setting = MEDIA.GetSetting(k)

    if (setting.Type == MEDIA.Types.TABLE) then
        for key,value in pairs(v) do
            local typ

            if (string.sub(key, 1, 2) == "__") then
                continue
            end

            if (type(value) == "boolean") then
                typ = MEDIA.Types.BOOL
            elseif (type(value) == "number") then
                typ = MEDIA.Types.INT
            else
                typ = MEDIA.Types.BOOL
            end

            create(value, key, typ)
        end
    else
        create(v, k, setting.Type)
    end
end

vgui.Register("MEDIA.PresetPreview", panel, "MEDIA.BasePanel")