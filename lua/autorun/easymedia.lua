--only does this once
if (LydsPlayer == nil or table.IsEmpty(LydsPlayer)) then
    LydsPlayerErrors = {}

    --original error function
    local originalError = error

    --rewrite it
    error = function(...)
        errorBad(...)
    end

    --warning func
    warning = function(...)
        local seed = "Server"
        LydsPlayerErrors.Recoverable = LydsPlayerErrors.Recoverable or {}

        if (CLIENT) then
            seed = "Client"
        end

        LydsPlayerErrors.Recoverable[ seed ] = LydsPlayerErrors.Recoverable[ seed ] or {}
        LydsPlayerErrors.Recoverable[ seed ][ #LydsPlayerErrors.Recoverable[ seed ] ] =  {
            Time = os.time(),
            ...
        }

        hook.Run("OnWarning", {...})

        ErrorNoHalt(...)
    end

    --error
    errorBad = function(...)
        local seed = "Server"
        LydsPlayerErrors.Bad = LydsPlayerErrors.Bad or {}

        if (CLIENT) then
            seed = "Client"
        end

        LydsPlayerErrors.Bad[ seed ] = LydsPlayerErrors.Bad[ seed ] or {}
        LydsPlayerErrors.Bad[ seed ][ #LydsPlayerErrors.Bad[ seed ] + 1 ] = {
            Time = os.time(),
            ...
        }

        if (#LydsPlayerErrors.Bad[ seed ] == 0) then
            hook.Run("OnFirstBadError", {...})
        else
            hook.Run("OnBadError", {...})
        end

        originalError(...)
    end

    --save it when we shut down
    hook.Add("ShutDown", "SaveErrors", function()
        if (!file.IsDir("lyds/errors", "DATA")) then file.CreateDir("lyds/errors", "DATA") end

        for f,v in pairs(LydsPlayerErrors) do
            if (CLIENT) then
                file.Write("lyds/errors/" .. f .. " " .. game.GetMap() .. "_" .. os.date("%A_%B%d_%y %H_%M_%S") .. " CLIENT.json", util.TableToJSON(v["Client"], true))
            elseif (SERVER) then
                file.Write("lyds/errors/" .. f .. " " .. game.GetMap() .. "_" .. os.date("%A_%B%d_%y %H_%M_%S") .. " SERVER.json", util.TableToJSON(v["Server"], true))
            end
        end
    end)
end

--our global table
LydsPlayer = LydsPlayer or {
    Name = "Easy MediaPlayer",
    Credits = {
        Author = "llydia",
        Email = "llydia@zyon.io",
        SteamID = "STEAM_0:1:31630" --doesn't do anything
    },
    Version = 0.2,
    Type = {
        INT = "int", --can be a convar
        STRING = "string", --can be a convar
        BOOL = "bool", --can be a convar
        TABLE = "table", --cant be a convar,
        FLOAT = "float"
    },
    LastError = nil,
    LastWarning = nil,
    Files = {}, --see below,
    --metatable stuff (unused)
    _new = function()
        return setmetatable(table.Copy(LydsPlayer), LydsPlayer)
    end,
    __index = LydsPlayer
}

--holds our computer colours
LydsPlayer.ComputedColours = LydsPlayer.ComputedColours or {}

--the colours for our stuff
LydsPlayer.Colours = {
    Black = Color(35,35,35),
    Gray = Color(145,145,145),
    PitchBlack = Color(0,0,0),
    SmokeyWhite = Color(195,195,195),
    White = Color(255,255,255),
    Red = Color(255,0,0),
    Pink = Color(255,0,200),
    Blue = Color(0,0,255)
}

--generates some colours but only once
if (table.IsEmpty(LydsPlayer.ComputedColours)) then

    for key,colour in pairs(LydsPlayer.Colours) do
        LydsPlayer.ComputedColours[ "Faded" .. key ] = Color(colour.r, colour.g, colour.b, 200 )
        LydsPlayer.ComputedColours[ "Barely" .. key ] = Color(colour.r, colour.g, colour.b, 75 )
        LydsPlayer.ComputedColours[ "Transparent" .. key ] = Color(colour.r, colour.g, colour.b, 25 )
        LydsPlayer.ComputedColours[ "Reverse" .. key ] = Color(colour.b, colour.g, colour.r, 255 )
    end
end

if (!table.IsEmpty(LydsPlayer.ComputedColours)) then
    LydsPlayer.Colours = table.Merge(LydsPlayer.Colours, LydsPlayer.ComputedColours)
end

--autoloader for our scripts

--loads shared files
for k,v in pairs(file.Find("lyds/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/" .. v)
    end
    include("lyds/" .. v)

    LydsPlayer.Files.Shared =  LydsPlayer.Files.Shared or {}
    LydsPlayer.Files.Shared["lyds/" .. v] = v
end

--loads server files (does not index dirs)
if (SERVER) then
    for k,v in pairs(file.Find("lyds/server/*.lua","LUA")) do
        include("lyds/server/" .. v)
        LydsPlayer.Files.Server = LydsPlayer.Files.Server or {}
        LydsPlayer.Files.Server["lyds/server/" .. v] = v
    end
end

--loads client files (does not index dirs)
for k,v in pairs(file.Find("lyds/client/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/client/" .. v)
    else
        include("lyds/client/" .. v)
        LydsPlayer.Files.Client = LydsPlayer.Files.Client or {}
        LydsPlayer.Files.Client["lyds/client/" .. v] = v
    end
end
