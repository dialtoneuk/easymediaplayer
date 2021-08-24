--all of the live, loaded panels in the addon sit here
MediaPlayer.LoadedPanels = MediaPlayer.LoadedPanels or {}

--called when context menu opened
function MediaPlayer.ExecuteContextMenu(has_opened)
	has_opened = has_opened or false

	--loop through all our loaded panels and execute the OnContext method
	for k,v in pairs(MediaPlayer.LoadedPanels) do
		if ( v.OnContext != nil ) then
			v.OnContext(MediaPlayer.LoadedPanels[k].Panel, k, MediaPlayer.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--called when scoreboard menu opened
function MediaPlayer.ExecuteScoreboardMenu(has_opened)
	has_opened = has_opened or false

	--loop through all our loaded panels and execute the OnScoreboard method
	for k,v in pairs(MediaPlayer.LoadedPanels) do
		if ( v.OnScoreboard != nil ) then
			v.OnScoreboard(MediaPlayer.LoadedPanels[k].Panel, k, MediaPlayer.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--loads all the panels required by our system
function MediaPlayer.InstantiatePanels(reinstantiate, skip, only_do)
	skip = skip or {}
	only_do = only_do or {}
	reinstantiate = reinstantiate or false

	for key,v in pairs(MediaPlayer.Panels) do

		if (v.Preloaded != nil and !v.Preloaded and !table.HasValue(only_do, key)) then continue end
		if (table.HasValue(skip, key)) then continue end
		if (!table.IsEmpty(only_do) and !table.HasValue(only_do, key)) then continue end

		MediaPlayer.Panels[key]._Settings = {}

		MediaPlayer.SetPanelSettings(key, table.Merge(MediaPlayer.Panels[key].Settings, {
			Size = MediaPlayer.Panels[key].SettingsBase .. "_size",
			Position = MediaPlayer.Panels[key].SettingsBase .. "_position",
			Hide = MediaPlayer.Panels[key].SettingsBase .. "_hide",
			Centered = MediaPlayer.Panels[key].SettingsBase .. "_centered",
		}), MediaPlayer.Panels[key].SettingsBase)

		if (MediaPlayer.LoadedPanels[key] != nil and IsValid(MediaPlayer.LoadedPanels[key].Panel) ) then

			if (reinstantiate) then
				if (IsValid(MediaPlayer.LoadedPanels[key].Panel)) then
					MediaPlayer.LoadedPanels[key].Panel:Remove()
				end
			else
				continue
			end
		end

		MediaPlayer.LoadedPanels[key] = table.Merge(MediaPlayer.Panels[key], {
			Panel = vgui.Create("MediaPlayer." .. MediaPlayer.Panels[key].Element)
		})

		MediaPlayer.SetupPanel(MediaPlayer.LoadedPanels[key]._Settings, MediaPlayer.LoadedPanels[key].Panel, key)

		--overwrite our hide to essentially ignore it if show all isn't present
		MediaPlayer.LoadedPanels[key].Panel._Hide = MediaPlayer.LoadedPanels[key].Panel.Hide
		MediaPlayer.LoadedPanels[key].Panel.Hide = function()
			local _as = MediaPlayer.GetSetting("all_show")
			if ( _as.Value == false ) then
				MediaPlayer.LoadedPanels[key].Panel:_Hide()
			end
		end

		--implicit hide
		if (MediaPlayer.LoadedPanels[key].IsVisible == nil or !MediaPlayer.LoadedPanels[key].IsVisible) then
			MediaPlayer.LoadedPanels[key].Panel:Hide()
		end

		MediaPlayer.LoadedPanels[key].PostInit(MediaPlayer.LoadedPanels[key].Panel, key, MediaPlayer.LoadedPanels[key]._Settings)
	end
end

--only instantiates a singular panel
function MediaPlayer.ReinstantiatePanel(key, reopen)
	reopen = reopen or false
	MediaPlayer.InstantiatePanels(true, {}, {
		key
	})

	if (reopen) then
		MediaPlayer.ShowPanel(key)
	end
end

--shows a panel
function MediaPlayer.ShowPanel(key)
	MediaPlayer.LoadedPanels[key].Panel:Show()
end

--gets the panel class attached to the object
function MediaPlayer.GetPanel(key)
	return 	MediaPlayer.LoadedPanels[key].Panel
end

--returns true only if the value of the Panel key is a valid panel
function MediaPlayer.PanelValid(key)
	return MediaPlayer.LoadedPanels[key] != nil and MediaPlayer.LoadedPanels[key].Panel != nil and IsValid(MediaPlayer.LoadedPanels[key].Panel)
end

--hides a panel
function MediaPlayer.HidePanel(key)
	MediaPlayer.LoadedPanels[key].Panel:Hide()
end

--sets the internal settings of panel to that of real settings
function MediaPlayer.SetPanelSettings(key, tab, settings_base)
	settings_base = settings_base or ""
	for k,v in pairs(tab) do
		if (string.find(v, settings_base) == nil ) then
			v = settings_base .. "_" .. v
		end

		if (MediaPlayer.Settings[v] == nil ) then
			warning(v .. " does not exist so default to base")
			v = string.Replace(v, settings_base, "base")
		end

		MediaPlayer.Panels[key]._Settings[k] = MediaPlayer.GetSetting(v)
	end
end

--sets up a panel with its default pos, size, and other specifications
function MediaPlayer.SetupPanel(settings, panel, key)
	panel:SetSize(settings.Size.Value.Width, settings.Size.Value.Height)
	panel:SetPos(settings.Position.Value.X, settings.Position.Value.Y)

	if (settings.Centered.Value) then
		panel:IgnoreReposition()
		panel:Center()
	end

	--for dframes
	if (panel.SetDraggable != nil ) then
		panel:SetDraggable(MediaPlayer.LoadedPanels[key].Draggable)

		if (!settings.Centered.Value) then
			panel._Reposition = !MediaPlayer.LoadedPanels[key].Draggable
		end
	end

	if (panel.SetDeleteOnClose != nil ) then
		panel:SetDeleteOnClose(false)
	end

	panel.OnClose = function(self)
		self:Hide()
	end
end