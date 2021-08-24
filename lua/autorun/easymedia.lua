--only does this once
if (MediaPlayer == nil or table.IsEmpty(MediaPlayer)) then
    MediaPlayerErrors = {}

    --original error function
    local originalError = error

    --rewrite it
    error = function(...)
        errorBad(...)
    end

    --warning func
    warning = function(...)
        local seed = "Server"
        MediaPlayerErrors.Recoverable = MediaPlayerErrors.Recoverable or {}

        if (CLIENT) then
            seed = "Client"
        end

        MediaPlayerErrors.Recoverable[ seed ] = MediaPlayerErrors.Recoverable[ seed ] or {}
        MediaPlayerErrors.Recoverable[ seed ][ #MediaPlayerErrors.Recoverable[ seed ] ] =  {
            Time = os.time(),
            ...
        }

        hook.Run("OnWarning", {...})

        ErrorNoHalt(...)
    end

    --error
    errorBad = function(...)
        local seed = "Server"
        MediaPlayerErrors.Bad = MediaPlayerErrors.Bad or {}

        if (CLIENT) then
            seed = "Client"
        end

        MediaPlayerErrors.Bad[ seed ] = MediaPlayerErrors.Bad[ seed ] or {}

        if (#MediaPlayerErrors.Bad[ seed ] == 0) then
            hook.Run("OnFirstBadError", {...})
        end

        MediaPlayerErrors.Bad[ seed ][ #MediaPlayerErrors.Bad[ seed ] + 1 ] = {
            Time = os.time(),
            ...
        }

        hook.Run("OnBadError", {...})

        originalError(...)
    end

    --save it when we shut down
    hook.Add("ShutDown", "SaveErrors", function()
        if (!file.IsDir("lyds/errors", "DATA")) then file.CreateDir("lyds/errors", "DATA") end

        for f,v in pairs(MediaPlayerErrors) do
            if (CLIENT) then
                file.Write("lyds/errors/" .. f .. " " .. os.date("%A_%B%d_%y %H_%M_%S") .. " CLIENT.json", util.TableToJSON(v["Client"], true))
            elseif (SERVER) then
                file.Write("lyds/errors/" .. f .. " " .. os.date("%A_%B%d_%y %H_%M_%S") .. " SERVER.json", util.TableToJSON(v["Server"], true))
            end
        end
    end)
end

--our global table
MediaPlayer = MediaPlayer or {
    Name = "Easy MediaPlayer",
    Credits = {
        Author = "llydia",
        Email = "llydia@zyon.io",
        SteamID = "STEAM_0:1:31630" --doesn't do anything
    },
    Version = 1.9,
    Type = {
        INT = "int", --can be a convar
        STRING = "string", --can be a convar
        BOOL = "bool", --can be a convar
        TABLE = "table", --cant be a convar,
        FLOAT = "float"
    },
    Files = {} --see below
}

--autoloader for our scripts

--loads shared files
for k,v in pairs(file.Find("lyds/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/" .. v)
    end
    include("lyds/" .. v)

    MediaPlayer.Files.Shared =  MediaPlayer.Files.Shared or {}
    MediaPlayer.Files.Shared["lyds/" .. v] = v
end

--loads server files (does not index dirs)
if (SERVER) then
    for k,v in pairs(file.Find("lyds/server/*.lua","LUA")) do
        include("lyds/server/" .. v)
        MediaPlayer.Files.Server = MediaPlayer.Files.Server or {}
        MediaPlayer.Files.Server["lyds/server/" .. v] = v
    end
end

--loads client files (does not index dirs)
for k,v in pairs(file.Find("lyds/client/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/client/" .. v)
    else
        include("lyds/client/" .. v)
        MediaPlayer.Files.Client = MediaPlayer.Files.Client or {}
        MediaPlayer.Files.Client["lyds/client/" .. v] = v
    end
end
