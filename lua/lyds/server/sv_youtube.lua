
--gets duration, title, creator, views and other information about a youtube video
function LydsPlayer.GetYoutubeVideoInfo(video, callback)
	LydsPlayer.YoutubeVideoExists(video, function(result)
		if (!result or result == nil) then callback(false) return end

		LydsPlayer.YoutubeGetVideo(video, function(data)
			video.Duration = LydsPlayer.ConvertFromISOTime(data.contentDetails.duration)
			video.Title = data.snippet.title
			video.Creator = data.snippet.channelTitle
			video.Views = data.statistics.viewCount

			if ( callback != nil) then
				callback(video)
			end
		end)
	end)
end

--returns true if a video exists
function LydsPlayer.YoutubeVideoExists(video, callback)

	--This gets the info then executes a callback
	LydsPlayer.YoutubeIsValid(video, function(data)
		if (data == nil) then
			callback(false)
		elseif (!table.IsEmpty(data)) then
			callback(true)
		else

			if (LydsPlayer.IsSettingTrue("youtube_deep_check")) then
				LydsPlayer.YoutubeGetVideo(video, function(r)
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

--preforms a youtube search, returns a table full of objects as the first argument in the callbacks parameter
function LydsPlayer.YoutubeSearch(query, callback, count)
	count = count or 1

	if (type(callback) != "function") then
		error("callback must be a function")
	end

	local params = "search?q=" .. LydsPlayer.EncodeURI(query) .. "&part=snippet&maxResults=" .. math.floor(count) .. "&type=video"
	LydsPlayer.YoutubeFetch(params, callback)
end

--queries youtube and gets information about a video, takes a table or the id of a video
function LydsPlayer.YoutubeGetVideo(video, callback)

	if (type(video) == "table") then
		video = video.Video
	end

	if (type(callback) != "function") then
		error("callback must be a function")
	end

	local params = "videos?id=" .. video .. "&part=snippet,contentDetails,statistics,status,player"
	LydsPlayer.YoutubeFetch(params, callback, true )
end

--returns true if a video is valid
function LydsPlayer.YoutubeIsValid(video, callback)

	if (type(video) == "table") then
		video = video.Video
	end

	local params = "https://www.youtube.com/oembed?url=http://www.youtube.com/watch?v=" .. video .. "&format=json"
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
