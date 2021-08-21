
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
