--[[
Sets the info for a video, including its duration
--]]

function MediaPlayer.GetYoutubeVideoInfo(video, callback)
	MediaPlayer.YoutubeVideoExists(video, function(result)
		if (!result or result == nil) then callback(false) return end

		MediaPlayer.YoutubeGetDeepInfo(video, function(data)
			video.Duration = MediaPlayer.ConvertFromISOTime(data.contentDetails.duration)
			video.Title = data.snippet.title
			video.Creator = data.snippet.channelTitle
			video.Views = data.statistics.viewCount
			video.Player = data.player

			if ( callback != nil) then
				callback(video)
			end
		end)
	end)
end

--[[
Does a free check to see if a video exists using the api-less call (takes up no use of API key limit)
--]]

function MediaPlayer.YoutubeVideoExists(video, callback)

	--This gets the info then executes a callback
	MediaPlayer.YoutubeGetFreeInfo(video, function(data)
		if (data == nil) then
			callback(false)
		elseif (!table.IsEmpty(data)) then
			callback(true)
		else

			if (MediaPlayer.IsSettingTrue("youtube_deep_check")) then
				MediaPlayer.YoutubeGetDeepInfo(video, function(r)
					if (table.IsEmpty(r)) then
						callback(false)
					else
						callback(true)
					end
				end)
			else
				callback(false)
			end
		end
	end)
end

--[[
	This will search MediaPlayer and return videos for us.
--]]

function MediaPlayer.YoutubeSearch(query, callback, count)
	count = count or 1

	local params = "search?q=" .. MediaPlayer.EncodeURI(query) .. "&part=snippet&maxResults=" .. math.floor(count) .. "&type=video"
	MediaPlayer.YoutubeFetch(params, callback)
end

--[[
	This gets data about a video and then calls a callback
--]]

function MediaPlayer.YoutubeGetDeepInfo(video, callback)

	local params = "videos?id=" .. video.Video .. "&part=snippet,contentDetails,statistics,status,player"
	MediaPlayer.YoutubeFetch(params, callback, true )
end

--[[
	Gets free info which does not take from your api key limit
--]]

function MediaPlayer.YoutubeGetFreeInfo(video, callback)

	local params = "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=" .. video.Video .. "&format=json"
	http.Fetch( params, function( body, length, headers, code )
		if (code == 404) then
			callback({})
			return
		end

		if (body == "Not Found" or body == "Unauthorized") then
			callback({})
		else
			callback(util.JSONToTable(body))
		end
	end,
	function( message )
		print(params .. " probably not found")
	end, {["accept-encoding"] = "gzip, deflate"})
end
