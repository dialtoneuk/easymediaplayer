--all of the live, loaded panels in the addon sit here
LydsPlayer.LoadedPanels = LydsPlayer.LoadedPanels or {}

--called when context menu opened
function LydsPlayer.ExecuteContextMenu(has_opened)
	has_opened = has_opened or false

	--loop through all our loaded panels and execute the OnContext method
	for k,v in pairs(LydsPlayer.LoadedPanels) do
		if ( v.OnContext != nil ) then
			LydsPlayer.LoadedPanels[k].Panel:SetInContext(has_opened)
			v.OnContext(LydsPlayer.LoadedPanels[k].Panel, k, LydsPlayer.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--called when scoreboard menu opened
function LydsPlayer.ExecuteScoreboardMenu(has_opened)
	has_opened = has_opened or false

	--loop through all our loaded panels and execute the OnScoreboard method
	for k,v in pairs(LydsPlayer.LoadedPanels) do
		if ( v.OnScoreboard != nil ) then
			LydsPlayer.LoadedPanels[k].Panel:SetInScoreboard(has_opened)
			v.OnScoreboard(LydsPlayer.LoadedPanels[k].Panel, k, LydsPlayer.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--loads all the panels required by our system
function LydsPlayer.InstantiatePanels(reinstantiate, skip, only_do)
	skip = skip or {}
	only_do = only_do or {}
	reinstantiate = reinstantiate or false

	for key,v in pairs(LydsPlayer.Panels) do

		if (v.Preloaded != nil and !v.Preloaded and !table.HasValue(only_do, key)) then continue end
		if (table.HasValue(skip, key)) then continue end
		if (!table.IsEmpty(only_do) and !table.HasValue(only_do, key)) then continue end

		LydsPlayer.Panels[key]._Settings = {}

		LydsPlayer.SetPanelSettings(key, table.Merge(LydsPlayer.Panels[key].Settings, {
			Size = LydsPlayer.Panels[key].SettingsBase .. "_size",
			Position = LydsPlayer.Panels[key].SettingsBase .. "_position",
			Hide = LydsPlayer.Panels[key].SettingsBase .. "_hide",
			Centered = LydsPlayer.Panels[key].SettingsBase .. "_centered",
			AutoResize = LydsPlayer.Panels[key].SettingsBase .. "_auto_resize",
		}), LydsPlayer.Panels[key].SettingsBase)

		if (LydsPlayer.LoadedPanels[key] != nil and IsValid(LydsPlayer.LoadedPanels[key].Panel) ) then

			if (reinstantiate) then
				if (IsValid(LydsPlayer.LoadedPanels[key].Panel)) then
					LydsPlayer.LoadedPanels[key].Panel:Remove()
				end
			else
				continue
			end
		end

		LydsPlayer.LoadedPanels[key] = table.Merge(LydsPlayer.Panels[key], {
			Panel = vgui.Create("LydsPlayer." .. LydsPlayer.Panels[key].Element)
		})

		LydsPlayer.SetupPanel(LydsPlayer.LoadedPanels[key]._Settings, LydsPlayer.LoadedPanels[key].Panel, key)

		--overwrite our hide to essentially ignore it if show all isn't present
		LydsPlayer.LoadedPanels[key].Panel._Hide = LydsPlayer.LoadedPanels[key].Panel.Hide
		LydsPlayer.LoadedPanels[key].Panel.Hide = function()
			local _as = LydsPlayer.GetSetting("all_show")
			if ( _as.Value == false ) then
				LydsPlayer.LoadedPanels[key].Panel:_Hide()
			end
		end

		--implicit hide
		if (LydsPlayer.LoadedPanels[key].IsVisible == nil or !LydsPlayer.LoadedPanels[key].IsVisible) then
			LydsPlayer.LoadedPanels[key].Panel:Hide()
		end

		LydsPlayer.LoadedPanels[key].PostInit(LydsPlayer.LoadedPanels[key].Panel, key, LydsPlayer.LoadedPanels[key]._Settings)
	end
end

--only instantiates a singular panel
function LydsPlayer.ReinstantiatePanel(key, reopen)
	reopen = reopen or false
	LydsPlayer.InstantiatePanels(true, {}, {
		key
	})

	if (reopen) then
		LydsPlayer.ShowPanel(key)
	end
end

--shows a panel
function LydsPlayer.ShowPanel(key)
	LydsPlayer.LoadedPanels[key].Panel:Show()
end

--gets the panel class attached to the object
function LydsPlayer.GetPanel(key)
	return 	LydsPlayer.LoadedPanels[key].Panel
end

--returns true only if the value of the Panel key is a valid panel
function LydsPlayer.PanelValid(key)
	return LydsPlayer.LoadedPanels[key] != nil and LydsPlayer.LoadedPanels[key].Panel != nil and IsValid(LydsPlayer.LoadedPanels[key].Panel)
end

--hides a panel
function LydsPlayer.HidePanel(key)
	LydsPlayer.LoadedPanels[key].Panel:Hide()
end

--sets the internal settings of panel to that of real settings
function LydsPlayer.SetPanelSettings(key, tab, settings_base)
	settings_base = settings_base or ""
	for k,v in pairs(tab) do
		if (string.find(v, settings_base) == nil ) then
			v = settings_base .. "_" .. v
		end

		if (LydsPlayer.Settings[v] == nil ) then
			warning(v .. " does not exist so default to base")
			v = string.Replace(v, settings_base, "base")
		end

		LydsPlayer.Panels[key]._Settings[k] = LydsPlayer.GetSetting(v)
	end
end

--sets up a panel with its default pos, size, and other specifications
function LydsPlayer.SetupPanel(settings, panel, key)

	if (!settings.AutoResize.Value) then
		panel:SetSize(settings.Size.Value.Width, settings.Size.Value.Height)
	end

	if (!panel.Locked) then
		panel:SetPos(settings.Position.Value.X, settings.Position.Value.Y)
	end

	if (settings.Centered.Value) then
		panel:LockPanel()
		panel:Center()
	end

	--for dframes
	if (panel.SetDraggable != nil ) then
		panel:SetDraggable(LydsPlayer.LoadedPanels[key].Draggable)

		if (!settings.Centered.Value) then
			panel._Reposition = !LydsPlayer.LoadedPanels[key].Draggable
		end
	end

	if (panel.SetDeleteOnClose != nil ) then
		panel:SetDeleteOnClose(false)
	end

	panel.OnClose = function(self)
		self:Hide()
	end
end