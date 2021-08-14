MEDIA.LoadedPanels = MEDIA.LoadedPanels or {}

--called when context menu opened
function MEDIA.ExecuteContextMenu(has_opened)
	has_opened = has_opened or false

	for k,v in pairs(MEDIA.LoadedPanels) do
		if ( v.OnContext != nil ) then
			v.OnContext(MEDIA.LoadedPanels[k].Panel, k, MEDIA.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--called when scoreboard menu opened
function MEDIA.ExecuteScoreboardMenu(has_opened)
	has_opened = has_opened or false

	for k,v in pairs(MEDIA.LoadedPanels) do
		if ( v.OnScoreboard != nil ) then
			v.OnScoreboard(MEDIA.LoadedPanels[k].Panel, k, MEDIA.LoadedPanels[k]._Settings, has_opened)
		end
	end
end

--loads all the panels required by our system
function MEDIA.InstantiatePanels(reinstantiate, skip, only_do)
	skip = skip or {}
	only_do = only_do or {}
	reinstantiate = reinstantiate or false

	for key,v in pairs(MEDIA.Panels) do

		if (table.HasValue(skip, key)) then continue end
		if (!table.IsEmpty(only_do) and !table.HasValue(only_do, key)) then continue end

		MEDIA.Panels[key]._Settings = {}
		MEDIA.SetPanelSettings(key, table.Merge(MEDIA.Panels[key].Settings, {
			Size = MEDIA.Panels[key].SettingsBase .. "_size",
			Position = MEDIA.Panels[key].SettingsBase .. "_position",
			Hide = MEDIA.Panels[key].SettingsBase .. "_hide",
			Centered = MEDIA.Panels[key].SettingsBase .. "_centered",
		}), MEDIA.Panels[key].SettingsBase)

		if (MEDIA.LoadedPanels[key] != nil ) then

			if (reinstantiate) then
				if (IsValid(MEDIA.LoadedPanels[key].Panel)) then
					MEDIA.LoadedPanels[key].Panel:Remove()
				end
			else
				continue
			end
		end

		MEDIA.LoadedPanels[key] = table.Merge(MEDIA.Panels[key], {
			Panel = vgui.Create("MEDIA." .. MEDIA.Panels[key].Element)
		})

		MEDIA.SetupPanel(MEDIA.LoadedPanels[key]._Settings, MEDIA.LoadedPanels[key].Panel, key)

		--overwrite our hide to essentially ignore it if show all isn't present
		MEDIA.LoadedPanels[key].Panel._Hide = MEDIA.LoadedPanels[key].Panel.Hide
		MEDIA.LoadedPanels[key].Panel.Hide = function()
			local _as = MEDIA.GetSetting("media_all_show")
			if ( _as.Value == false ) then
				MEDIA.LoadedPanels[key].Panel:_Hide()
			end
		end

		--implicit hide
		if (MEDIA.LoadedPanels[key].IsVisible != nil and MEDIA.LoadedPanels[key].IsVisible) then
			MEDIA.LoadedPanels[key].Panel:Hide()
		end

		MEDIA.LoadedPanels[key].PostInit(MEDIA.LoadedPanels[key].Panel, key, MEDIA.LoadedPanels[key]._Settings)
	end
end

--only instantiates a singular panel
function MEDIA.ReinstantiatePanel(key, reopen)
	reopen = reopen or false
	MEDIA.InstantiatePanels(true, {}, {
		key
	})

	if (reopen) then
		MEDIA.ShowPanel(key)
	end
end

--shows a panel
function MEDIA.ShowPanel(key)
	MEDIA.LoadedPanels[key].Panel:Show()
end

function MEDIA.GetPanel(key)
	return 	MEDIA.LoadedPanels[key].Panel
end

--hides a panel
function MEDIA.HidePanel(key)
	MEDIA.LoadedPanels[key].Panel:Hide()
end

function MEDIA.SetPanelSettings(key, tab, settings_base)
	settings_base = settings_base or ""
	for k,v in pairs(tab) do

		if (string.find(v, settings_base) == nil ) then
			v = settings_base .. "_" .. v
		end

		MEDIA.Panels[key]._Settings[k] = MEDIA.GetSetting(v)
	end
end

function MEDIA.SetupPanel(settings, panel, key)
	panel:SetSize(settings.Size.Value.Width, settings.Size.Value.Height)
	panel:SetPos(settings.Position.Value.X, settings.Position.Value.Y)

	if (settings.Centered.Value == true ) then
		panel:Center()
	end

	--for dframes
	if (panel.SetDraggable != nil ) then
		panel:SetDraggable(MEDIA.LoadedPanels[key].Draggable)
	end

	if (panel.SetDeleteOnClose != nil ) then
		panel:SetDeleteOnClose(false)
	end

	panel.OnClose = function(self)
		self:Hide()
	end
end


--[[
	function to create all client panels
]]--

function MEDIA.CreateClientPanels()
	print("DEPRACATED! CreateClientPanels call somewhere")
	MEDIA.InstantiatePanels(true)
end
