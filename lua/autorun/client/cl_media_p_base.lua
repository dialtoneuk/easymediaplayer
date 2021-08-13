local base = {}
base.Name = "base"
base.RescaleWidth = true
base.RescaleHeight = true
base.ActiveRefresh = true
base._Reposition = true
base.InvertPosition = false
base._Resized = false

--[[
Init
]]
function base:BaseInit()
    self:RefreshPanelSettings()
    self:Reposition()
end

function base:Init()
    self:CacheThink()
end

--only use in panel:MyThink()
function base:HasResized()
    return self._Resized == true
end

--another way of saying it
function base:HasRefreshed()
    return self:HasResized()
end

--[[

]]
function base:GetSettingKey(type)
    type = type or "colours"

    return "media_" .. self.Name .. "_" .. type
end

--[[
To fix dragging
]]
function base:CacheThink()
    --hack to get window dragging to keep working too if we override think
    self._Think = self.Think

    self.Think = function()
        self._Resized = false

        if (self._Think ~= nil) then
            self:_Think()
        end

        self:BaseThink()

        if (self.MyThink ~= nil) then
            self:MyThink()
        end
    end
end

--[[

*]]
function base:RefreshPanelSettings()
    self.Settings = self.Settings or {}
    self.Settings.Colours = MEDIA.GetSetting(self:GetSettingKey("colours"))
    self.Settings.Position = MEDIA.GetSetting(self:GetSettingKey("position"))
    self.Settings.Size = MEDIA.GetSetting(self:GetSettingKey("size"))
end

--[[
Resizes
]]
function base:BaseThink()
    if (self.ActiveRefresh) then
        self:RefreshPanelSettings()
    end

    self:ResizePanel()

    if (self._Reposition) then
        self:Reposition()
    end
end

function base:ResizePanel()
    if (self.RescaleWidth and self:GetWide() ~= math.floor(self.Settings.Size.Value.Width)) then
        self:SetWide(self.Settings.Size.Value.Width)
        self._Resized = true
    end

    if (self.RescaleHeight and self:GetTall() ~= math.floor(self.Settings.Size.Value.Height)) then
        self:SetTall(self.Settings.Size.Value.Height)
        self._Resized = true
    end
end

--[[
Sets the vote position
]]
function base:Reposition()
    if (self.Centered or not self.Settings.Position) then return end
    local x = self.Settings.Position.Value.X or 10
    local y = self.Settings.Position.Value.Y or 10
    x = math.floor(x)
    y = math.floor(y)

    if (self:GetX() ~= x or self:GetY() ~= y) then
        if (not self.InvertPosition) then
            self:SetPos(x, y)
        else
            self:SetPos(ScrW() - (self.Settings.Size.Value.Width + self.Settings.Position.Value.X or 10), self.Settings.Position.Value.Y or 10)
        end
    end
end

--copy it
local panel = table.Copy(base)
--Register
vgui.Register("MEDIA_Base", base, "DFrame")
vgui.Register("MEDIA_BasePanel", panel, "DPanel") --register an exact copy but for a panel too