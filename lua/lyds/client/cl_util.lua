function MediaPlayer.CreateWarningBox(title, message, timeout)
	timeout = timeout or false

	MediaPlayer.ReinstantiatePanel("WarningBox")
	MediaPlayer.GetPanel("WarningBox"):SetWarning(title, message, timeout)
end

function MediaPlayer.CreateSuccessBox(title, message, timeout)
	timeout = timeout or false

	MediaPlayer.ReinstantiatePanel("SuccessBox")
	MediaPlayer.GetPanel("SuccessBox"):SetBox(title, message, timeout)
end
