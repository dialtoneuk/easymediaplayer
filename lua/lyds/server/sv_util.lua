
--Sends a preset to the player
function LydsPlayer.SendDefaultPreset(ply, usmg)
    usmg = usmg or "Apply"
    local tab = util.JSONToTable( file.Read("lyds/presets/server_preset.json", "DATA") )

    if (usmg != "Apply" and usmg != "Refresh" ) then
       error("invalid user message start (is CaseSensitive):  " .. usmg)
    end
    if (table.IsEmpty(tab)) then return end

    net.Start("LydsPlayer." .. usmg .. "DefaultPreset")
        net.WriteTable(tab)
    net.Send(ply)
end

function LydsPlayer.GetEnabledMediaTypes()

    local t = {}

    for k,v in pairs(LydsPlayer.MediaType) do
        if (LydsPlayer.HasSetting(v .. "_enabled") and LydsPlayer.IsSettingTrue(v .. "_enabled")) then
            t[v] = true
        end
    end

    return t
end

function LydsPlayer.SendEnabledMediaTypes(ply, tab)
    net.Start("LydsPlayer.EnabledMediaTypes")
        net.WriteTable(tab)
    net.Send(ply)
end

--saves the servers joinlist to a json file
function LydsPlayer.SaveJoinlist()

    if (LydsPlayer.Joinlist == nil or table.IsEmpty(LydsPlayer.Joinlist)) then return end

    file.Write("lyds/join_list.json", util.TableToJSON(LydsPlayer.Joinlist))
end