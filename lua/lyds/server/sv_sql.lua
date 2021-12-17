LydsPlayer.Table = {
    Video = "TEXT",
    Title = "TEXT",
    Creator = "TEXT",
    Likes = "NUMBER",
    Dislikes = "NUMBER",
    Plays = "NUMBER",
    SteamID = "TEXT",
    Type = "TEXT",
    LastPlayed = "NUMBER"
}

function LydsPlayer.InsertHistory(obj)

    local r = sql.Query("INSERT into media_history " .. LydsPlayer.GetTableStructure()
    .. " VALUES (" .. LydsPlayer.CollapseTable({
        Video = obj.Video,
        Title = obj.Title,
        Creator = obj.Creator,
        Likes = obj.Likes or 0,
        Dislikes = obj.Dislikes or 0,
        Plays = obj.Plays or 0,
        SteamID = obj.Owner.SteamID,
        Type = obj.Type,
        LastPlayed = obj.LastPlayed or os.time()
    }) .. ");")

    if (r == false ) then
        error(sql.LastError())
    end

    print("inserted " .. obj.Video)
end

function LydsPlayer.UpdateHistory(video, obj)

    local q = "UPDATE media_history SET " .. LydsPlayer.CollapseTable({
        Video = obj.Video,
        Title = obj.Title,
        Creator = obj.Creator,
        Likes = obj.Likes,
        Dislikes = obj.Dislikes,
        Plays = obj.Plays,
        SteamID = obj.Owner.SteamID,
        Type = obj.Type,
        LastPlayed = obj.LastPlayed
    }, true) .. " WHERE Video = " .. sql.SQLStr(video) .. ";"
    local r = sql.Query(q)

    if (r == false ) then
        error(sql.LastError())
    end

    print("updated " .. obj.Video)
end

function LydsPlayer.GetVideoHistory(video)
    local r = sql.QueryValue("SELECT * FROM media_history WHERE Video = '" .. video .. "'")

    if (r == false ) then
        error(sql.LastError())
    end

    return r
end

function LydsPlayer.GetHistory(orderby, asc, limit, page)
    limit = limit or LydsPlayer.GetSettingInt("media_history_max")
    page = page or 0
    orderby = orderby or  "Plays"

    if (asc) then
        orderby = orderby .. " ASC"
    else
        orderby = orderby .. " DESC"
    end


    local obj = sql.Query("SELECT * FROM media_history" .. " ORDER BY " .. orderby .. " LIMIT " .. limit .. " OFFSET " .. limit * page)

    if (obj == false) then
        error(sql.LastError())
    else
        if (table.IsEmpty(obj)) then
            return {}
        end
    end

    return obj
end


function LydsPlayer.ExistsInDatabase(Video)

    local r = sql.QueryValue("SELECT * FROM media_history WHERE Video = " .. sql.SQLStr(Video) .. "")


    if (r == false ) then
        error(sql.LastError())
    end

    if (r == nil) then
        print("Video does not exist: " .. Video )
        return false
    end

    return true
end


function LydsPlayer.GetPlayerHistory(id, orderby, asc, limit, page)
    limit = limit or LydsPlayer.GetSettingInt("media_history_max")
    orderby = orderby or  "Plays"
    page = page or 0

    if (asc) then
        orderby = orderby .. " ASC"
    else
        orderby = orderby .. " DESC"
    end

    local r = sql.Query("SELECT * FROM media_history WHERE SteamID = " .. sql.SQLStr(id) .. " ORDER BY " .. orderby .. " LIMIT " .. limit .. " OFFSET " .. limit * page)

    if (r == false ) then
        error(sql.LastError())
    end

    return r
end


function LydsPlayer.CheckSqlTableExists()
    --creates table if it does not exist
    local r = sql.Query("CREATE TABLE IF NOT EXISTS media_history" .. LydsPlayer.GetTableStructure(true) .. ";")

    if (r == false) then
        error(sql.LastError())
    end
end

function LydsPlayer.DropTable()
    --creates table if it does not exist
    local r = sql.Query("DROP TABLE media_history;")

    if (r == false) then
        error(sql.LastError())
    end
end

function LydsPlayer.CollapseTable(tab, equals)
    equals = equals or false

    local str = ""

    for k,v in pairs(tab) do
        if (type(tab[k]) != "string") then continue end
        tab[k] = sql.SQLStr(tab[k])
    end

    for k,v in pairs(tab) do
        if (equals) then
            str = str .. k .. " = " .. v .. ", "
        else
            str = str .. v .. ", "
        end
    end

    return string.sub(str, 1, #str-2)
end


function LydsPlayer.GetTableStructure(typ)
    typ = typ or false
    local str = ""

    for k,v in pairs(LydsPlayer.Table) do

        if (typ) then
            str = str .. k .. " " .. v .. ", "
        else
            str = str .. k ..  " " .. ", "
        end
    end

    return "(" .. string.sub(str, 1, #str-2) .. ")"
end