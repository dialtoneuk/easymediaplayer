local base = {}

base.Name = "base"
base.ActiveRefresh = true
base.InvertXPosition = false
base.InvertYPosition = false
base.RescaleWidth = true
base.RescaleHeight = true
base._Reposition = true
base._Rescaled = false
base._RowHeight = 0
base._Padding = 0

base._OnChange = {
    Width = function(p)
        if (p.RescaleWidth and p:GetWide() != p:GetPaddedWidth()) then
            p:SetWide(p:GetPaddedWidth())
            p._Rescaled = true
        end
        p:SetWide(p:GetPaddedWidth())
    end,
    Height = function(p)
        if (p.RescaleHeight and p:GetTall() != p:GetPaddedHeight()) then
            p:SetTall(p:GetPaddedHeight())
            p._Rescaled = true
        end
    end
}

base._RefreshSettings = {
    Colours = "colours",
    Position = "position",
    Size = "size"
}

function base:Init()
    self:CacheThink()
end

function base:BaseInit()
    self.OnChange = table.Merge(table.Copy(self._OnChange), self.OnChange or {})
    self.RefreshSettings = table.Merge(table.Copy(self._RefreshSettings), self.RefreshSettings or {})

    self:RefreshPanelSettings()
    self:Reposition()
    self:ExecuteOperations()
end

function base:IgnoreRescaling(height, width)

    self.RescaleHeight = !height
    self.RescaleWidth = !width
end


--only use in panel:MyThink()
function base:HasRescaled()
    return self._Rescaled == true
end

--another way of saying it
function base:HasRefreshed()
    return self:HasRescaled()
end

function base:InvertPosition(x, y )
    x = x or false
    y = y or false
    self.InvertXPosition = x
    self.InvertYPosition = y
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
        self._Rescaled = false

        if (self._Think != nil) then
            self:_Think()
        end

        self:BaseThink()

        if (self.MyThink != nil) then
            self:MyThink()
        end
    end
end

--rerefesh _OnChange settings
function base:RefreshPanelSettings()
    self.Settings = self.Settings or {}
    for k,v in pairs(self.RefreshSettings) do
        self.Settings[k] = MEDIA.GetSetting(self:GetSettingKey(v))
    end
end

function base:IgnoreReposition()
    self._Reposition = false
end

--[[
Resizes
]]
function base:BaseThink()
    if (self.ActiveRefresh) then
        self:RefreshPanelSettings()
    end

    self:ExecuteOperations()
    self:Reposition()
end

function base:ExecuteOperations()

    if (self.OnChange == nil) then return end
    for k,v in pairs(self.OnChange) do
        self.OnChange[k](self)
    end
end

function base:ResizePanel()
    self:ExecuteOperations()
end

function base:RescalePanel()
    self:ExecuteOperations()
end

function base:SimpleDockPadding(element)
    element = element or self
    element:DockPadding(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
end

function base:SimpleDockMargin(element)
    element = element or self
    element:DockMargin(self:GetPadding(),self:GetPadding(),self:GetPadding(),self:GetPadding())
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

    return math.Truncate(padding)
end

function base:IsSettingTrue(key)

    if (self.Settings[key] == nil ) then
        errorBad(key .. " is nil")
    end

    return self.Settings[ key ].Value == true or self.Settings[ key ].Value == 1
end

function base:GetPaddedWidth(set_padding, neg)
    neg = neg or false
    return math.Truncate(self.Settings.Size.Value.Width + self:GetPadding(neg))
end

function base:GetPaddedHeight(set_padding, neg)
    neg = neg or false
    return math.Truncate(self.Settings.Size.Value.Height + self:GetPadding(neg))
end

--[[
Sets the vote position
]]
function base:Reposition()
    if (!self._Reposition or self.Centered or self.Settings.Position == nil) then return end

    local x = self.Settings.Position.Value.X
    local y = self.Settings.Position.Value.Y
    x = math.floor(x)
    y = math.floor(y)

    if (!self.InvertXPosition) then
        self:SetPos(x, y)
    else
        self:SetPos(ScrW() - (self:GetPaddedWidth() + self.Settings.Position.Value.X), self.Settings.Position.Value.Y)
    end
end

--copy it
local panel = table.Copy(base)
local button = table.Copy(base)

--Register
vgui.Register("MEDIA.Base", base, "DFrame")
vgui.Register("MEDIA.BasePanel", panel, "DPanel") --register an exact copy but for a panel too
vgui.Register("MEDIA.BaseButton", button, "DButton") --register an exact copy but for a panel too