if (MediaPlayer == nil or table.IsEmpty(MediaPlayer)) then
    _errorLog = {}

    --overwrite error stuff
    _error = error

    error = function(...)
        errorBad(...)
    end

    warning = function(...)
        local seed = "Server"
        _errorLog.Recoverable = _errorLog.Recoverable or {}

        if (CLIENT) then
            seed = "Client"
        end

        _errorLog.Recoverable[ seed ] = _errorLog.Recoverable[ seed ] or {}
        _errorLog.Recoverable[ seed ][ #_errorLog.Recoverable[ seed ] ] =  {
            Time = os.time(),
            ...
        }

        hook.Run("OnWarning", {...})
        ErrorNoHalt(...)
    end


    errorBad = function(...)
        local seed = "Server"
        _errorLog.Bad = _errorLog.Bad or {}

        if (CLIENT) then
            seed = "Client"
        end

        _errorLog.Bad[ seed ] = _errorLog.Bad[ seed ] or {}

        if (#_errorLog.Bad[ seed ] == 0) then
            hook.Run("OnFirstBadError", {...})
        end

        _errorLog.Bad[ seed ][ #_errorLog.Bad[ seed ] + 1 ] = {
            Time = os.time(),
            ...
        }

        hook.Run("OnBadError", {...})

        _error(...)
    end


    hook.Add("ShutDown", "SaveErrors", function()
        if (!file.IsDir("lyds/errors", "DATA")) then file.CreateDir("lyds/errors", "DATA") end

        for f,v in pairs(_errorLog) do
            if (CLIENT) then
                file.Write("lyds/errors/" .. f .. " " .. os.date("%A_%B%d_%y %H_%M_%S") .. " CLIENT.json", util.TableToJSON(v["Client"], true))
            elseif (SERVER) then
                file.Write("lyds/errors/" .. f .. " " .. os.date("%A_%B%d_%y %H_%M_%S") .. " SERVER.json", util.TableToJSON(v["Server"], true))
            end
        end
    end)
end

MediaPlayer = MediaPlayer or {
    Name = "Easy MediaPlayer",
    Credits = {
        Author = "llydia",
        Email = "llydia@zyon.io",
        SteamID = "STEAM_0:1:31630"
    },
    Version = 1.9,
    Type = {
        INT = "int", --can be a convar
        STRING = "string", --can be a convar
        BOOL = "bool", --can be a convar
        TABLE = "table", --cant be a convar,
        FLOAT = "float"
    },
    Files = {}
}

MediaPlayer.SettingsTypes = MediaPlayer.Type
MediaPlayer.SettingTypes = MediaPlayer.Type
MediaPlayer.Types = MediaPlayer.Type

--autoloader for our scripts
for k,v in pairs(file.Find("lyds/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/" .. v)
    end
    include("lyds/" .. v)

    MediaPlayer.Files.Shared =  MediaPlayer.Files.Shared or {}
    MediaPlayer.Files.Shared["lyds/" .. v] = v
end

if (SERVER) then
    for k,v in pairs(file.Find("lyds/server/*.lua","LUA")) do
        include("lyds/server/" .. v)
        MediaPlayer.Files.Server = MediaPlayer.Files.Server or {}
        MediaPlayer.Files.Server["lyds/server/" .. v] = v
    end
end

for k,v in pairs(file.Find("lyds/client/*.lua","LUA")) do
    if (SERVER) then
        AddCSLuaFile("lyds/client/" .. v)
    else
        include("lyds/client/" .. v)
        MediaPlayer.Files.Client = MediaPlayer.Files.Client or {}
        MediaPlayer.Files.Client["lyds/client/" .. v] = v
    end
end
