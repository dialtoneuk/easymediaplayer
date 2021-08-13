/*
Vote Panel
------------------------------------------------------------------------------
*/

local panel = {}

--panel settings
panel.Name = "vote"

--the vote
panel.Vote = {}

/*
Create vote panel
*/

function panel:Init()
	self:BaseInit()
	self:DockPadding(15,15,15,15)

	self.Type = vgui.Create("DLabel", self )
	self.Type:Dock(TOP)
	self.Type:SetFont("BigText")
	self.Type:SetText("Unknown Vote (0)")
	self.Type:SizeToContents()

	self.VOwner = vgui.Create("DLabel", self )
	self.VOwner:Dock(LEFT)
	self.VOwner:SizeToContents()
	self.VOwner:SetText("Penisman")

	if ( self.Settings.Colours != nil) then
		self.Paint = function()
			surface.SetDrawColor(self.Settings.Colours.Value.Background)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
			surface.SetDrawColor(self.Settings.Colours.Value.Border)
			surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())

			if (self.Vote and !table.IsEmpty(self.Vote) and self.Vote.StartTime  ) then
				local time = CurTime() - self.Vote.StartTime
				mins = math.floor(time / 60)
				seconds = math.floor(time - (mins * 60))

				if (seconds < 10) then
					seconds = "0" .. seconds
				end

				local str =  mins .. ":" .. seconds
				local w = surface.GetTextSize(str)

				draw.SimpleTextOutlined(str, "MediumText", self:GetWide() - w - 10 , self:GetTall() - 45, MEDIA.Colours.White, 10, 1, 0.5,  MEDIA.Colours.Black )
				surface.SetDrawColor(self.Settings.Colours.Value.LoadingBarBackground )
				surface.DrawRect( 0, 0, math.Clamp( self:GetWide() * (time / 10), 5, self:GetWide() ), 5)
			end
		end
	end
end

/*

*/

function panel:MyThink()
	if (self.Settings.Size != nil) then
		self.Type:SetWide(self:GetWide())
		self.VOwner:SetWide(self:GetWide())
	end
end

/*

*/

function panel:Reset()
	self.Vote = nil
	self.Type:SetText("Unknown Vote (0)")
	self.VOwner:SetText("Penisman")
end

/*
Sets the vote
*/

function panel:SetVote(vote)
	self.Vote = vote
	self.Type:SetText(vote.Type .. " (" .. vote.Count .. ")")
	self.VOwner:SetText(vote.Owner.Name)
end

--Register
vgui.Register("MEDIA_Vote", panel, "MEDIA_BasePanel")