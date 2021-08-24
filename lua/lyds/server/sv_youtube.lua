
--gets duration, title, creator, views and other information about a youtube video
function MediaPlayer.GetYoutubeVideoInfo(video, callback)
	MediaPlayer.YoutubeVideoExists(video, function(result)
		if (!result or result == nil) then callback(false) return end

		MediaPlayer.YoutubeGetVideo(video, function(data)
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

--returns true if a video exists
function MediaPlayer.YoutubeVideoExists(video, callback)

	--This gets the info then executes a callback
	MediaPlayer.YoutubeIsValid(video, function(data)
		if (data == nil) then
			callback(false)
		elseif (!table.IsEmpty(data)) then
			callback(true)
		else

			if (MediaPlayer.IsSettingTrue("youtube_deep_check")) then
				MediaPlayer.YoutubeGetVideo(video, function(r)
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
function MediaPlayer.YoutubeSearch(query, callback, count)
	count = count or 1

	if (type(callback) != "function") then
		error("callback must be a function")
	end

	local params = "search?q=" .. MediaPlayer.EncodeURI(query) .. "&part=snippet&maxResults=" .. math.floor(count) .. "&type=video"
	MediaPlayer.YoutubeFetch(params, callback)
end

--queries youtube and gets information about a video, takes a table or the id of a video
function MediaPlayer.YoutubeGetVideo(video, callback)

	if (type(video) == "table") then
		video = video.Video
	end

	if (type(callback) != "function") then
		error("callback must be a function")
	end

	local params = "videos?id=" .. video .. "&part=snippet,contentDetails,statistics,status,player"
	MediaPlayer.YoutubeFetch(params, callback, true )
end

--returns true if a video is valid
function MediaPlayer.YoutubeIsValid(video, callback)

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
