local base = {}

base.Name = "base"
base.RescaleWidth = true
base.RescaleHeight = true
base.ActiveRefresh = true
base._Reposition = true
base.InvertPosition = false
base._Resized = false
base._RowHeight = 0
base._Padding = 0

--[[
Init
]]
function base:BaseInit()
    self:RefreshPanelSettings()
    self:Reposition()
    self:ResizePanel()
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

        if (self._Think != nil) then
            self:_Think()
        end

        self:BaseThink()

        if (self.MyThink != nil) then
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

function base:SimpleDockPadding(element)
    element = element or false
    if (!element) then
        self:DockPadding(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
    else
        element:DockPadding(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
    end
end

function base:SimpleDockMargin(element)
    element = element or false
    if (!element) then
        self:DockMargin(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
    else
        element:DockMargin(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
    end
end

function base:GetPadding(neg)

    if (self.Settings == nil ) then
        self:RefreshPanelSettings()
    end

    neg = neg or false
    local padding = self.Settings.Size.Value.Padding or 0

    if (neg) then
        padding = padding - (padding * 2)
    end

    return padding
end

function base:GetSettingWidth(set_padding, neg)
    neg = neg or false
    return self.Settings.Size.Value.Width + self:GetPadding(neg)
end

function base:GetSettingHeight(set_padding, neg)
    neg = neg or false
    return self.Settings.Size.Value.Height + self:GetPadding(neg)
end

function base:ResizePanel()
    if (self.RescaleWidth and self:GetWide() != math.floor(self:GetSettingWidth())) then
        self:SetWide(self:GetSettingWidth())
        self._Resized = true
    end

    if (self.RescaleHeight and self:GetTall() != math.floor(self:GetSettingHeight())) then
        self:SetTall(self:GetSettingHeight())
        print("r")
        self._Resized = true
    end

    if (self.Settings.Size.Value.RowHeight != nil and self.Settings.Size.Value.RowHeight != self._RowHeight ) then
        self._RowHeight =  self.Settings.Size.Value.RowHeight
        self._Resized = true
    end

    if (self.Settings.Size.Value.Padding != nil and self.Settings.Size.Value.Padding != self._Padding ) then
        self._Padding =  self.Settings.Size.Value.Padding
        self._Resized = true
    end
end

--[[
Sets the vote position
]]
function base:Reposition()
    if (self.Centered or self.Settings.Position == nil) then return end

    local x = self.Settings.Position.Value.X or 10
    local y = self.Settings.Position.Value.Y or 10
    x = math.floor(x)
    y = math.floor(y)

    if (self:GetX() != x or self:GetY() != y) then
        if (!self.InvertPosition) then
            self:SetPos(x, y)
        else
            self:SetPos(ScrW() - (self:GetSettingWidth() + self.Settings.Position.Value.X), self.Settings.Position.Value.Y)
        end
    end
end

--copy it
local panel = table.Copy(base)
--Register
vgui.Register("MEDIA.Base", base, "DFrame")
vgui.Register("MEDIA.BasePanel", panel, "DPanel") --register an exact copy but for a panel too