--settings for the settings panel
local server = {} --

local client = {
    --
    settings_centered = {
        Value = false,
        Refresh = false,
        Comment = "The settings window will open centered to the middle of your screen."
    },
    settings_hide = {
        Value = true,
        Comment = "Disabling this will mean the settings panel will constantly be visible, making the creation of presets easier."
    },
    settings_invert_position = {
        Value = false,
        Comment = "Inverts the x position of the settings panel, you can use this to make things position from the right of the screen instead of the left."
    },
    settings_auto_resize = {
        Value = false,
        Comment = "The settings panel will scale relative to gui_resize_scale."
    },
    settings_resize_scale = {
        Value = 0.75,
        Refresh = false,
        Max = 2.0,
        Type = LydsPlayer.Type.FLOAT,
        Comment = "Changing this to a lower value will make the panel appear bigger when auto_resize is enabled. This is divided by the current gui_resize_scale value."
    },
    settings_colours = {
        Value = {
            __unpack = function(self, index, value) return LydsPlayer.TableToColour(value) end, --called when unpacking from save json
            __pack = function(self, index, value) return value end, --called when packing data into json.
            Background = LydsPlayer.Colours.FadedBlack,
            SecondaryBackground = LydsPlayer.Colours.FadedGray,
            Border = LydsPlayer.Colours.FadedBlack,
            SecondaryBorder = LydsPlayer.Colours.FadedGray,
            TextColor = LydsPlayer.Colours.White
        }
    },
    settings_size = {
        Min = 15,
        Max = 2000,
        Value = {
            Width = 750,
            Height = 750,
            Padding = 15,
            RowHeight = 30
        },
        Refresh = false,
        SlowUpdate = 1,
    },
    settings_position = {
        Min = 10,
        Max = 2000,
        Value = {
            X = 25,
            Y = 25
        },
        Refresh = false
    },
    settings_options = {
        Min = 1,
        Max = 256,
        Value = {
            BorderThickness = 2,
            PropertyRowSpacing = 32,
            DisplayTitle = false,
            PropertyMinHeight = 64
        },
        Refresh = true
    }
}

hook.Add("LydsPlayer.SettingsLoaded", "LydsPlayer.RegisterSettings", function()
    LydsPlayer.RegisterSettings(server, client)
end)