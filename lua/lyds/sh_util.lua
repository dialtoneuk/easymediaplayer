
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
	Verifies an mp3 url
--]]

function MediaPlayer.VerifyMp3URL(url)

	url = string.Trim(url)

	if (string.find(".mp3", url) == nil ) then
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
