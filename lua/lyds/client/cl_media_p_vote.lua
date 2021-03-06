--[[
Vote Panel
------------------------------------------------------------------------------
--]]

local panel = {}

--panel settings
panel.Name = "vote"

panel.Settings = {
    CenterHorizontally = "center_horizontally",
}

--[[
Create vote panel
--]]

function panel:Init()
	self:BaseInit({
		Padding = true,
		Declare = {
			Vote = {}
		},
		Locked = true
	})

	if (self.Settings.CenterHorizontally.Value) then
		self:SetPos(ScrW() / 2 - ( self:GetWidth() / 2 ), self.Settings.Position.Value.Y )
	else
		self:SetPos(self.Settings.Position.Value.X, self.Settings.Position.Value.Y)
	end

	self.Type = vgui.Create("DLabel", self )
	self.Type:Dock(TOP)
	self.Type:SetFont("BigText")
	self.Type:SetText("Unknown Vote (0)")
	self.Type:SetTextColor(self.Settings.Colours.Value.TextColor)
	self.Type:SizeToContents()

	self.VOwner = vgui.Create("DLabel", self )
	self.VOwner:Dock(LEFT)
	self.VOwner:SizeToContents()
	self.VOwner:SetText("Penisman")
	self.VOwner:SetTextColor(self.Settings.Colours.Value.TextColor)
end

function panel:Paint(p)
	surface.SetDrawColor(self.Settings.Colours.Value.Background)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	surface.SetDrawColor(self.Settings.Colours.Value.Border)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), self.Settings.Options.Value.BorderThickness)

	if (self.Vote and !table.IsEmpty(self.Vote) and self.Vote.StartTime  ) then
		local time = CurTime() - self.Vote.StartTime
		local mins = math.floor(time / 60)
		local seconds = math.floor(time - (mins * 60))

		if (seconds < 10) then
			seconds = "0" .. seconds
		end

		local str =  mins .. ":" .. seconds
		local w = surface.GetTextSize(str)

		draw.SimpleTextOutlined(str, "MediumText", self:GetWide() - w - 10 , self:GetTall() - 45, LydsPlayer.Colours.White, 10, 1, 0.5,  LydsPlayer.Colours.Black )
		surface.SetDrawColor(self.Settings.Colours.Value.LoadingBarBackground )
		surface.DrawRect( 0, 0, math.Clamp( ( self:GetWide() / self.Vote.Time ) * time , 5, self:GetWide() ), self.Settings.Size.Value.LoadingBarHeight)
	end
end

--think
function panel:MyThink()
	if (self:HasResized()) then
		self.Type:SetWide(self:GetWidth())
		self.VOwner:SetWide(self:GetWidth())
	end
end

--[[

--]]

function panel:Reset()
	self.Vote = nil
	self.Type:SetText("Unknown Vote (0)")
	self.VOwner:SetText("Penisman")
end

--[[
Sets the vote
--]]

function panel:SetVote(vote)
	self.Vote = vote
	self.Type:SetText(vote.Type .. " (" .. vote.Count .. "/" .. vote.Required .. ")")
	self.VOwner:SetText(vote.Owner.Name)
end

--Register
vgui.Register("LydsPlayer.VotePanel", panel, "LydsPlayer.BasePanel")