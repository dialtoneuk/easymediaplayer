--[[
	Parses a url from MediaPlayer
--]]

function MediaPlayer.ParseYoutubeURL(url) --bad method

	if (url == "https://www.youtube.com"  or url == "http://youtube.com" ) then return nil end
	if (string.sub(url, 1,23) != "https://www.youtube.com" and string.sub(url, 1,23) != "http://youtube.com" ) then return nil end

	local str = string.match(url, "?v=[a-zA-Z0-9_/]+") --bad method

	if (str == nil) then return nil end

	str = string.Replace(str, "?v=", "") --ugh
	return str
end

--[[
 Fetches Dailymotion api data
--]]

function MediaPlayer.DailymotionFetch(params, callback, one_object)

end

--[[
 Fetches Dailymotion api data
--]]

function MediaPlayer.DailymotionFetch(params, callback, one_object)
	one_object = one_object or false

	local apikey = MediaPlayer.GetSetting("dailymotion_api_key")

	if (CLIENT) then
		apikey = MediaPlayer.GetSetting("dailymotion_client_api_key")
	end

	if (apikey.Value == apikey.DefValue or false ) then
		error([[dailymotion_api_key not set! please goto https://console.cloud.google.com/google/ and create a new api key, it must have access to the Youtube 'Data' V3 Api,
		then, type MediaPlayer_settings into console and find dailymotion_api_key and put in your new api key, and try again.]])
	end
end

--[[
 Fetches youtube api data
--]]

function MediaPlayer.YoutubeFetch(params, callback, one_object)
	one_object = one_object or false

	local apikey = MediaPlayer.GetSetting("youtube_api_key")

	if (CLIENT) then
		apikey = MediaPlayer.GetSetting("youtube_client_api_key")
	end

	if (apikey.Value == apikey.DefValue or false ) then
		error([[youtube_api_key not set! please goto https://console.cloud.google.com/google/ and create a new api key, it must have access to the Youtube 'Data' V3 Api,
		then, type MediaPlayer_settings into console and find youtube_api_key and put in your new api key, and try again.]])
	end

	params = "https://www.googleapis.com/youtube/v3/" .. params .. "&key=" .. apikey.Value

	http.Fetch( params, function( body, length, headers, code )
		if ( code == 404) then
			errorBad(params .. " not found")
		end

		if ( code == 400 ) then
			errorBad("youtube_api_key is invalid!")
		end

		local json = util.JSONToTable(body) or {
			error = {
				"JSON parse failed check body",
				body = body
			}
		}

		if (json.error) then
			PrintTable(json.error)
			errorBad("http.fetch error " .. body)
		elseif (table.IsEmpty(json.items)) then
			callback({})
		else

			if (json.items == nil ) then
				callback(json)
				return
			end

			if (one_object) then
				callback(json.items[1])
			else
				callback(json.items)
			end
		end
	end, function( message )
		print(params .. " failed")
	end, {["accept-encoding"] = "gzip, deflate"})
end
--[[
	Converts ISO time to a numerical value
--]]
function MediaPlayer.ConvertFromISOTime(duration)

	local safeFunc = function()
		local time = string.gsub(duration, "^.-(%d+)M(%d+)S","%1:%2")

		if (string.sub(duration, 4,4 ) == "H") then
			time = string.sub(duration,3,3) .. ":" .. time
		else
			time = 0 .. ":" .. time
		end

		local exp = string.Explode(":",time)

		--lame fix
		if (#exp == 1) then
			return MediaPlayer.ConvertFromISOTime(duration .. "1S")
		end

		local total = 0

		for k,v in pairs(exp) do
			if (v == nil) then return end
			if (k == 1) then
				total = total + ( tonumber(v) * 60 * 60 ) --hours
			elseif (k == 2) then
				total = total  + ( tonumber(v) * 60 ) --minutes
				continue
			end
			total = total  + ( tonumber(v)  ) --seconds
		end

		return total
	end

	local status, val = pcall(safeFunc)

	if (!status) then
		return 0
	end

	return val
end