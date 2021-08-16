if (MEDIA == nil or table.IsEmpty(MEDIA)) then
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

MEDIA = MEDIA or {
    Name = "Easy Media Player",
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
}

MEDIA.SettingsTypes = MEDIA.Type
MEDIA.SettingTypes = MEDIA.Type
MEDIA.Types = MEDIA.Type