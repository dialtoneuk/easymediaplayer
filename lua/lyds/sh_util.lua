MediaPlayer.BaseSeed = math.floor( os.time() / 3600 )

--[[
Encode URI
--]]

function MediaPlayer.EncodeURI(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end

--[[
Decode URI
--]]

function MediaPlayer.DecodeURI(s)
	if (s) then
		s = string.gsub(s, "%%(%x%x)", function (hex)
			return string.char(tonumber(hex,16))
		end)
	end
	return s
end

--[[
Turns a table into a colour
--]]

function MediaPlayer.TableToColour(tab)
	return Color(tab.r or tab[1], tab.g or tab[2], tab.b or tab[3], tab.a or tab[4] or 255)
end

function MediaPlayer.VarToColour(...)
	local tab = {...}
	return MediaPlayer.TableToColour(tab[1])
end
--[[
Gens an id based off of a string (url in our usecase for the mp3 stuff)
--]]
function MediaPlayer.GenerateUniqueID(stringy)
	local seed = 0
	local id = ""

	for i = 1, #stringy do
		seed = seed + string.byte(stringy, i, i) --get the bytevalue of each of our string addit all together
	end

	seed = seed * MediaPlayer.BaseSeed --times it all together

	if (seed < 1000) then
		seed = seed * 10
	end

	local str = tostring(seed)

	for i = 1, #str do --then by the length of the seed string
		local c = string.sub(str, i, i) --take a singular number
		id = id .. string.char( 100 + tonumber(c) ) --add it to char
	end

	while (#id < 12) do
		id = id .. "_"
	end

	return id
end

--[[
	Verifies an mp3 url
--]]

function MediaPlayer.VerifyMp3URL(url)
	ensure_https = ensure_https or false
	url = string.Trim(url)

	if (string.find(url, ".mp3") == nil ) then
		return false
	end

	if (string.sub(url, 1, 8) == "https://" or string.sub(url, 1, 8) == "http://" ) then
		return false
	end

	local exp = string.Explode(".", url)

	if (table.IsEmpty(exp)) then
		return false
	end

	if (exp[#exp] != "mp3") then
		return false
	end

	return true
end
