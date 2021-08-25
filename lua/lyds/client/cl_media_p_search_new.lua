local panel = {}

panel.Name = "search"

panel.Settings = {
    --putting ! will not  append the panel name to key when getting this setting
    ResizeScale = "!gui_resize_scale",
    AutoResize = "auto_resize"
}

/*
    Needs to be able to search/request different types of media
    Needs to be able to present history
    Needs a web browser
*/

function panel:Init()
    self:BaseInit({
        DontResize = {
            Width = true,
            Height = true
        }
    })

    if (!self:IsSettingTrue("AutoResize")) then
        self:SetIgnoreScaling(false, false)
        self:Rescale()
    else
        self:RescaleTo(self:GetSettingInt("ResizeScale"))
    end
end

--vgui.Create("MediaPlayer.SearchPanel", panel, "Media.Base")