local base = {}

--default updates
base._Updates = {
	Size = {
		Width = function(p)
			if (p:CheckChange("Width") and p:CanResizeWidth() ) then
				p:SetWide(p:GetSettingWidth())
				p:SetHasResized()
			end
		end,
		Height = function(p)
			if (p:CheckChange("Height") and p:CanResizeHeight() ) then
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
			if (p:CheckChange("Padding")) then
				p:SetHasResized()
			end
		end
	},
	Position = {
		X = function(p)
			if (p:CheckChange("X", "Position")) then
				if (p:IsLocked()) then return end
				if (p:IsCentered()) then return end

				if (p:IsXInverted()) then
					p:SetPos(ScrW() - p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position"))
				else
					p:SetPos(p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position"))
				end
			end
		end,
		Y = function(p)
			if (p:CheckChange("Y", "Position")) then
				if (p:IsLocked()) then return end
				if (p:IsCentered()) then return end

				if (p:IsYInverted()) then
					p:SetPos(p:GetIndexedSetting("X", "Position"), ScrH() - p:GetIndexedSetting("Y", "Position"))
				else
					p:SetPos(p:GetIndexedSetting("X", "Position"), p:GetIndexedSetting("Y", "Position"))
				end
			end
		end
	}
}

--default settings
base._Settings = {
	Colours = "colours",
	Position = "position",
	Size = "size",
	Options = "options",
	InvertPosition = "invert_position",
}


function base:SetInverted(x, y)
	y = y or false
	x = x or true

	if (self.Invert == nil) then
		self.Invert = {}
	end

	self.Invert.X = x
	self.Invert.Y = y
end

function base:LockPanel()
	self.Locked = true
end

function base:CanResizeHeight()
	return self.DontResize.Height == false
end

function base:CanResizeWidth()
	return self.DontResize.Width == false
end

function base:IsLocked()
	return self.Locked
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
	return self.Resized
end

function base:HasRescaled()
	return self.Resized
end

function base:SetHasResized()
	self.Resized = true
end

function base:SetOptions(options)
	self.Invert = options.invert or {
		X = false,
		Y = false
	}

	self.DontResize = options.Resize or {
		Width = false,
		Height = false
	}

	self.Centered = options.Centered or false
	self.Resized = options.Resized or false
	self.Locked = options.Locked or false
	self.Title = options.Title or self.Name

	if (options.PaddingPower) then
		self:SetDockPadding(self, options.PaddingPower)
	end

	if (options.Declare) then
		for k,v in pairs(options.Declare) do
			self[k] = v
		end
	end

	if (options.Padding) then
		self:SetDockPadding()
	end

	if (options.Margin) then
		self:SetDockPadding()
	end

	if (options.MargingPower) then
		self:SetDockMargin(self, options.MarginPower)
	end
end

function base:InvertXPosition()
	self.Invert.X = true
end

function base:RescaleTo(scale)
	scale = scale or 1

	local w = ScrW() / scale
	local h = ScrH() / scale

	self:SetWide(w + ( self:GetPadding() * 2 ))
	self:SetTall(h + ( self:GetPadding() * 2 ))
end

function base:GetSettingInt(key)

	if (type(self.Settings[key].Value) != "number") then
		error("invalid type not a number: " .. key )
	end

	return self.Settings[key].Value
end

function base:BaseInit(options)
	options = options or {}

	self.Updates = table.Merge(table.Copy(self._Updates), self.Updates or {})
	self.Settings = table.Merge(table.Copy(self._Settings), self.Settings or {})
	self.SettingChanges = {}

	self:SetPanelSettings()
	self:SetOptions(options)
	self:CacheThink()

	if (self:IsSettingTrue("InvertPosition")) then
		self:InvertXPosition(true)
	end

	if (self:CanResizeWidth()) then
		self:SetWide(self:GetWidth())
	end

	if (self:CanResizeHeight()) then
		self:SetHeight(self:GetHeight())
	end

	if (self.SetTitle == nil ) then
		self.SetTitle = function(t)
			self.Title = t
		end
	end

	if (self.Settings.Options.Value.DisplayTitle and self.Title) then
		self:SetTitle(self.Title)
	else
		self:SetTitle("")
	end

	self:Reposition()
end

function base:GetSettingWidth(padding, negative_padding)
	negative_padding = negative_padding or false
	local width = self:GetSetting("Size").Width

	if (padding and negative_padding) then
		width = width - (self:GetPadding() * 2)
	elseif (padding) then
		width = width + (self:GetPadding() * 2)
	end

	return width
end

base.GetWidth = base.GetSettingWidth

function base:GetSettingHeight(padding, negative_padding)
	negative_padding = negative_padding or false
	local height = self:GetSetting("Size").Height

	if (padding and negative_padding) then
		height = height - ( self:GetPadding() * 2)
	elseif (padding) then
		height = height + ( self:GetPadding() * 2 )
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

function base:Rescale()
	self:SetWidth(self:GetWidth())
	self:SetTall(self:GetHeight())
end

function base:SetIgnoreRescaling(width, height)
	width = width or true
	height = height or true

	if (self.DontResize == nil) then
		self.DontResize = {}
	end

	self.DontResize.Width = width
	self.DontResize.Height = height
end

base.IgnoreRescaling = base.SetIgnoreRescaling

function base:GetSetting(index)
	return self.Settings[index].Value
end

function base:CheckChange(key, index)
	index = index or "Size"

	if (self.SettingChanges[key] == nil) then
		self.SettingChanges[key] = self:GetIndexedSetting(key, index)

		return true
	elseif (self.SettingChanges[key] != self:GetIndexedSetting(key, index)) then
		self.SettingChanges[key] = self:GetIndexedSetting(key, index)

		return true
	end

	return false
end

function base:BaseThink()
	for k, v in pairs(self.Settings) do
		if (self.Updates[k] != nil) then
			if (v.Type == MediaPlayer.Type.TABLE) then
				for index, value in pairs(v.Value) do
					if (self.Updates[k][index] != nil) then
						self.Updates[k][index](self)
					end
				end
			else
				if (self.Updates[k] != nil) then
					self.Updates[k](self)
				end
			end
		end
	end
end

function base:SetDockPadding(element, times)
	element = element or self
	times = times or 1
	element:DockPadding(self:GetPadding() * times, self:GetPadding() * times, self:GetPadding() * times, self:GetPadding() * times)
end

function base:SetDockMargin(element, times)
	element = element or self
	times = times or 1
	element:DockMargin(self:GetPadding() * times, self:GetPadding() * times, self:GetPadding() * times, self:GetPadding() * times)
end

--rerefesh _OnChange settings
function base:SetPanelSettings()
	self.Settings = self.Settings or {}

	for k, v in pairs(self.Settings) do
		if (type(v) == "string") then
			self.Settings[k] = MediaPlayer.GetSetting(self:GetSettingKey(v))
		elseif (type(v) == "table") then
			self.Settings[k] = MediaPlayer.GetSetting(v.Key)
		end
	end
end

function base:Reposition()
	if (self.Centered or self.Locked) then return end
	local x = self.Settings.Position.Value.X
	local y = self.Settings.Position.Value.Y

	if (not self:IsXInverted() and not self:IsYInverted()) then
		self:SetPos(x, y)
	elseif (self:IsXInverted() and not self:IsYInverted()) then
		self:SetPos(ScrW() - (self:GetSettingWidth() + self.Settings.Position.Value.X), self.Settings.Position.Value.Y)
	elseif (self:IsYInverted() and not self:IsXInverted()) then
		self:SetPos(self.Settings.Position.Value.X, ScrH() - (self:GetSettingHeight() + self.Settings.Position.Value.Y))
	else
		self:SetPos(ScrW() - (self:GetSettingWidth() + self.Settings.Position.Value.X), ScrH() - (self:GetSettingHeight() + self.Settings.Position.Value.Y))
	end
end

function base:GetSettingKey(t)
	t = t or "colours"
	if (string.sub(t, 1, 1) == "!") then return string.sub(t, 2) end

	if (string.find(t, self.Name)) then
		warning("t already has extension present: " .. t)

		return t
	end

	return self.Name .. "_" .. t
end

function base:CacheThink()
	self._Think = self.Think

	self.Think = function()
		self.Resized = false

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