local panel = {}


function panel:Init()
    panel:BaseInit()

    self.PropertySheet = vgui.Create("DPropertySheet", self )
    self.PropertySheet:Dock(FILL)

    self.SearchContainer = vgui.Create("MediaPlayer.SearchResults", self.PropertySheet )
    self.SearchContainer:Dock(FILL)

    self.PropertySheet:AddSheet("Search", self.SearchContainer, "icon16/wand.png")
end