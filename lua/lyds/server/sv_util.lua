
--Sends a preset to the player
function MediaPlayer.SendDefaultPreset(ply, usmg)
    usmg = usmg or "Apply"
    local tab = util.JSONToTable( file.Read("lyds/presets/server_preset.json", "DATA") )

    if (usmg != "Apply" and usmg != "Refresh" ) then
       error("invalid user message start (is CaseSensitive):  " .. usmg)
    end
    if (table.IsEmpty(tab)) then return end

    net.Start("MediaPlayer." .. usmg .. "DefaultPreset")
        net.WriteTable(tab)
    net.Send(ply)
end

function MediaPlayer.GetEnabledMediaTypes()

    local t = {}

    for k,v in pairs(MediaPlayer.MediaType) do
        if (MediaPlayer.HasSetting(v .. "_enabled") and MediaPlayer.IsSettingTrue(v .. "_enabled")) then
            t[v] = true
        end
    end

    return t
end

function MediaPlayer.SendEnabledMediaTypes(ply, tab)
    net.Start("MediaPlayer.EnabledMediaTypes")
        net.WriteTable(tab)
    net.Send(ply)
end

--saves the servers joinlist to a json file
function MediaPlayer.SaveJoinlist()

    if (MediaPlayer.Joinlist == nil or table.IsEmpty(MediaPlayer.Joinlist)) then return end

    file.Write("lyds/join_list.json", util.TableToJSON(MediaPlayer.Joinlist))
end