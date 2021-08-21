function MediaPlayer.SendDefaultPreset(ply, usmg)
    usmg = usmg or "ApplyDefaultPreset"
    local tab = util.JSONToTable( file.Read("lyds/presets/server_preset.json", "DATA") )

    if (table.IsEmpty(tab)) then return end

    net.Start("MediaPlayer." .. usmg)
        net.WriteTable(tab)
    net.Send(ply)
end


function MediaPlayer.SaveJoinlist()

    if (MediaPlayer.Joinlist == nil or table.IsEmpty(MediaPlayer.Joinlist)) then return end

    file.Write("lyds/join_list.json", util.TableToJSON(MediaPlayer.Joinlist))
end