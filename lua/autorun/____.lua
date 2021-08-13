MEDIA = MEDIA or {
    Name = "Easy Media Player",
    Credits = {
        Author = "Llydia Cross",
        Email = "llydia@zyon.io",
        SteamID = "STEAM_0:1:31630"
    },
    Version = 1.7,
    Type = {
        INT = "int", --can be a convar
        STRING = "string", --can be a convar
        BOOL = "bool", --can be a convar
        TABLE = "table", --cant be a convar,
        FLOAT = "float"
    }
}

MEDIA.SettingsTypes = MEDIA.Type
MEDIA.SettingTypes = MEDIA.Type
MEDIA.Types = MEDIA.Type