--Used in the GenerateUniqueID method
LydsPlayer.BaseSeed = math.floor( os.time() / 3600 ) --hours since 1970

--Enocdes a string into URI format for use in a http call
function LydsPlayer.EncodeURI(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string.gsub (str, " ", "+")
	end
	return str
end

--Decodes a string used in a http call (unused)
function LydsPlayer.DecodeURI(s)
	if (s) then
		s = string.gsub(s, "%%(%x%x)", function (hex)
			return string.char(tonumber(hex,16))
		end)
	end
	return s
end

function LydsPlayer.AddFullStop(text)

	local escape = {
		"!","?","~",".","=","\n"
	}

	for k,v in pairs(escape) do
		if (string.sub(text, #text, #text) == v ) then
			return text
		end
	end

	return text .. "."
end

--Takes a table and returns a colour using the indexes of the table provided, must be numerical
function LydsPlayer.TableToColour(tab)
	return Color(tab.r or tab[1], tab.g or tab[2], tab.b or tab[3], tab.a or tab[4] or 255)
end

--Takes variable arguments as a parameter and turns them into a table
function LydsPlayer.VarToColour(...)
	local tab = {...}
	return LydsPlayer.TableToColour(tab[1])
end

--Generates a safe id based off of a master_string, the id returned will always be unique to the master_string
function LydsPlayer.GenerateSafeID(master_string)
	local seed = 0
	local id = ""

	for i = 1, #master_string do
		seed = seed + string.byte(master_string, i, i) --get the bytevalue of each of our string addit all together
	end

	seed = seed * LydsPlayer.BaseSeed --times it all together

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

--Verifies that an mp3 url is valid and in an acceptable format
function LydsPlayer.ValidMediaUrl(url)
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

--returns true is a URL is https
function LydsPlayer.IsUrlHTTPS(url)
	return string.sub(url, 1, 5) == "https"
end