
function MEDIA.CreateWarningBox(title, message, timeout)
    timeout = timeout or false

    MEDIA.ReinstantiatePanel("WarningBox")
    MEDIA.GetPanel("WarningBox"):SetWarning(title, message, timeout)
end