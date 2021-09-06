local panel = {}

panel.Name = "settings"

function panel:Init()
	self:BaseInit({
		Declare = {
			Values = {}
		}
	})

	self:SetDockPadding() --sets out dock padding

	self.Container = vgui.Create("DScrollPanel", self )
	self.Container:Dock(FILL)
	self.Container:DockMargin(0, 20, 0, 0)

	self.Grid = vgui.Create("DGrid", self.Container )
	self.Grid:SetCols( 1 ) --colours, position
	self.Grid:SetTall(self:GetHeight() - 30 + self:GetPadding() )
	self.Grid:SetPos( self:GetPadding(), self:GetPadding() )
	self.Grid:SetColWide(self:GetWidth())
	self.Grid:SetRowHeight( 55 + self:GetPadding() * 2 )

	self:SetDockMargin(self.Grid)
end

function panel:FillPanel(pan, k, v)
	local elm = vgui.Create("DPanel", pan)
	elm:SetWide( self:GetWidth() / 12 )
	elm:SetTall(45)
	elm:Dock(LEFT)
	elm.Paint = function() end

	self:SetDockPadding( elm )

	if (type(v) == "table") then
		local colour = v
		elm.Paint = function(el)
			draw.SimpleTextOutlined(k, "SmallText", 10, el:GetTall() / 2 + 8, MediaPlayer.Colours.White, 10, 1, 0.5, MediaPlayer.Colours.Black)
			surface.SetDrawColor(colour)
			surface.DrawOutlinedRect(0, 15,  el:GetWide(), el:GetTall() - 15,  4)
		end
	else

		if (type(v) == "boolean" and v == true) then
			v = "true"
		elseif (type(v) == "boolean") then
			v = "false"
		end

		elm.Paint = function(el)
			draw.SimpleTextOutlined(k, "SmallText", 15, 20, MediaPlayer.Colours.White, 10, 1, 0.5, MediaPlayer.Colours.Black)
			draw.SimpleText(v, "BigText", 15, 30, MediaPlayer.Colours.White)
		end
	end
end

function panel:SetPreview(settings)

	for k,v in pairs(settings) do
		local pan = vgui.Create("DPanel", self.Grid)
		pan:SetTall( 55 + self:GetPadding() * 2 )
		pan:SetWide( ( self:GetWidth(true, true ) - self:GetPadding() * 2 ) - 20 )

		pan.Paint = function(el)
			surface.SetDrawColor(self.Settings.Colours.Value.SecondaryBackground)
			surface.DrawRect(0, 0, el:GetWide(), 14 )
			surface.SetDrawColor(self.Settings.Colours.Value.SecondaryBorder)
			surface.DrawOutlinedRect( 2, 2,  el:GetWide() - 4, 14 - 4,  1)
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0,  el:GetWide(), 14,  1)
			draw.SimpleTextOutlined(k, "MediumText", 5, 6, MediaPlayer.Colours.White, 10, 1, 0.5, MediaPlayer.Colours.Black)
		end

		self:SetDockPadding(pan)

		local set = MediaPlayer.GetSetting(k)
		if (type(v) == "table") then
			for _, _v in pairs(v) do
				if ( type(_v) == "table") then
					if ( set != nil  and set.DefValue.__unpack ) then
						self:FillPanel(pan, _, set.DefValue.__unpack(settings[k][_], _, _v)) --doesn't work
					else
						self:FillPanel(pan, _, util.TableToJSON(_v) )
					end
				else
					self:FillPanel(pan, _, _v )
				end
			end
		else
			self:FillPanel(pan, "Value", v )
		end

		self.Grid:AddItem(pan)
	end
end

--Preview
vgui.Register("MediaPlayer.PresetPreviewWindow", panel, "MediaPlayer.Base")