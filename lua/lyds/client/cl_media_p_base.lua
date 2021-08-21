local base = {}

base._WatchedSettings = {
    Size = {
        Width = function(p)
            if (p:CheckChange("Width")) then
                p:SetWide(p:GetSettingWidth())
                p:SetHasResized()
            end
        end,
        Height = function(p)
            if (p:CheckChange("Height")) then
                p:SetTall(p:GetSettingHeight())
                p:SetHasResized()
            end
        end,
        RowHeight = function(p)
            if (p:CheckChange("RowHeight")) then
                p:SetHasResized()
            end
        end,
        Padding = function(p)
            if ( p:CheckChange("Padding") ) then
                p:SetHasResized()
            end
        end
    },
    Position = {
        X = function(p)
            if ( p:CheckChange("X", "Position") ) then
                if (p:IsLocked()) then return end
                if (p:IsCentered()) then return end
                if (p:IsXInverted()) then
                    p:SetPos( ScrW() - p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position") )
                else
                    p:SetPos( p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position") )
                end
            end
        end,
        Y = function(p)
            if ( p:CheckChange("Y", "Position") ) then
                if (p:IsLocked()) then return end
                if (p:IsCentered()) then return end
                if (p:IsYInverted()) then
                    p:SetPos( p:GetIndexedSetting("X", "Position"), ScrH() - p:GetIndexedSetting("Y", "Position") )
                else
                    p:SetPos( p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position") )
                end
            end
        end
    }
}

base._Settings = {
    Colours = "colours",
    Position = "position",
    Size = "size",
    Options = "options"
}

function base:CanResizeHeight()
    return self.Resize.Height
end

function base:IsLocked()
    return self.Locked
end

function base:CanResizeWidth()
    return self.Resize.Width
end

function base:IsXInverted()
    return self.Invert.X
end

function base:IsYInverted()
    return self.Invert.Y
end

function base:IsCentered()
    return self.Centered
end

function base:HasResized()
    return self._Resized
end


function base:SetHasResized()
    self._Resized = true
end

function base:SetInverted(x, y)
    y = y or false
    x = x or true

    if ( self.Invert == nil ) then
        self.Invert = {}
    end

    self.Invert.X = x
    self.Invert.Y = y
end


function base:LockPanel()
    self.Locked = true
end

function base:IgnoreReposition()
    self:LockPanel()
end

function base:BaseInit()
    self.WatchedSettings = table.Merge(table.Copy(self._WatchedSettings), self.WatchedSettings or {})
    self.Settings = table.Merge(table.Copy(self._Settings), self.Settings or {})

    self.InvertPosition = self.SetInverted
    self.HasRescaled = self.HasResized
    self.HasRescaled = self.HasResized

    self.Centered = false

    self.Invert = self.Invert or {
        X = false,
        Y = false
    }

    self._Changes = {}

    self.Resize = self.Resize or {
        Width = true,
        Height = true
    }

    self._Resized = false

    if (self.Name == nil ) then
        self.Name = "base"
    end

    self:SetPanelSettings()
    self:CacheThink()
end


function base:GetSettingWidth(padding, negative_padding)
    negative_padding = negative_padding or false

    local width = self:GetSetting("Size").Width
    if (padding and negative_padding) then
        width = width - self:GetPadding()
    elseif (padding) then
        width = width + self:GetPadding()
    end

    return width
end

base.GetWidth = base.GetSettingWidth

function base:GetSettingHeight(padding, negative_padding)
    negative_padding = negative_padding or false

    local height = self:GetSetting("Size").Height
    if (padding and negative_padding) then
        height = height - self:GetPadding()
    elseif (padding) then
        height = height + self:GetPadding()
    end

    return height
end

base.GetHeight = base.GetSettingHeight

function base:IsSettingTrue(key)

    return self:GetSetting(key) == true
end

function base:GetPadding()
    return self:GetSetting("Size").Padding or 0
end

function base:GetIndexedSetting(key, index)
    index = index or "Size"
    return self.Settings[index].Value[key]
end

function base:SetIgnoreRescaling(width, height)
    width = width or true
    height = height or true


    if ( self.Resize == nil ) then
        self.Resize = {}
    end

    self.Resize.Width = width
    self.Resize.Height = height
end

base.IgnoreRescaling = base.SetIgnoreRescaling

function base:GetSetting(index)
    return self.Settings[index].Value
end

function base:ExecuteOperations()

    warning("DEPRACATED CALL ExecuteOperations")
end

function base:ResizePanel()

    warning("DEPRACATED CALL ResizePanel")
end

function base:ResizePanel()

    warning("DEPRACATED CALL ResizePanel")
end

function base:CheckChange(key, index)
    index = index or "Size"

    if (self._Changes[key] == nil ) then
        self._Changes[key] = self:GetIndexedSetting(key, index)
        return true
    elseif (self._Changes[key] != self:GetIndexedSetting(key, index)) then
        self._Changes[key] = self:GetIndexedSetting(key, index)
        return true
    end

    return false
end

function base:BaseThink()

    for k,v in pairs(self.Settings) do
        if (self.WatchedSettings[k] != nil ) then
            if ( v.Type == MediaPlayer.Types.TABLE ) then
                for index,value in pairs(v.Value) do
                    if (self.WatchedSettings[k][index] != nil ) then
                        self.WatchedSettings[k][index](self)
                    end
                end
            else
                if (self.WatchedSettings[k] != nil ) then
                    self.WatchedSettings[k](self)
                end
            end
        end
    end
end

function base:SetDockPadding(element, times)
    element = element or self
    times = times or 1
    element:DockPadding(self:GetPadding() * times,self:GetPadding() * times,self:GetPadding() * times,self:GetPadding() * times)
end

function base:SetDockMargin(element)
    element = element or self
    times = times or 1
    element:DockMargin(self:GetPadding() * times,self:GetPadding() * times,self:GetPadding() * times,self:GetPadding() * times)
end

--rerefesh _OnChange settings
function base:SetPanelSettings()
    self.Settings = self.Settings or {}
    for k,v in pairs(self.Settings) do
        if (type(v) == "string") then
            self.Settings[k] = MediaPlayer.GetSetting(self:GetRealKey(v))
        elseif (type(v) == "table") then
            self.Settings[k] = MediaPlayer.GetSetting(v.Key)
        end
    end
end

--[[
Sets the vote position
]]
function base:Reposition()
    if (self.Centered or self.Locked) then return end

    local x = self.Settings.Position.Value.X
    local y = self.Settings.Position.Value.Y

    if (!self:IsXInverted() and !self:IsYInverted()) then
        self:SetPos(x, y)
    elseif (self:IsXInverted() and !self:IsYInverted()) then
        self:SetPos(ScrW() - (self:GetSettingWidth() + self.Settings.Position.Value.X), self.Settings.Position.Value.Y)
    elseif (self:IsYInverted() and !self:IsXInverted()) then
        self:SetPos(self.Settings.Position.Value.X, ScrH() - (self:GetSettingHeight() + self.Settings.Position.Value.Y))
    else
        self:SetPos(ScrW() - (self:GetSettingWidth() + self.Settings.Position.Value.X), ScrH() - (self:GetSettingHeight() + self.Settings.Position.Value.Y))
    end
end


function base:GetRealKey(t)
    t = t or "colours"

    if (string.sub(t, 1,1) == "!") then
        return string.sub(t, 2)
    end

    if (string.find(t, "media_" .. self.Name)) then
        warning("t already has extension present: " .. t )
        return t
    end

    return "media_" .. self.Name .. "_" .. t
end

function base:CacheThink()
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

--copy it
local panel = table.Copy(base)
local button = table.Copy(base)

--Register
vgui.Register("MediaPlayer.Base", base, "DFrame")
vgui.Register("MediaPlayer.BasePanel", panel, "DPanel") --register an exact copy but for a panel too
vgui.Register("MediaPlayer.BaseButton", button, "DButton") --register an exact copy but for a  too