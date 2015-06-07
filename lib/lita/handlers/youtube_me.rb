require "date"
require "iso8601"

module Lita
  module Handlers
    class YoutubeMe < Handler
      API_URL = "https://www.googleapis.com/youtube/v3"

      config :api_key, type: String, required: true
      config :video_info, types: [TrueClass, FalseClass], default: false
      config :detect_urls, types: [TrueClass, FalseClass], default: false
      config :top_result, types: [TrueClass, FalseClass], default: false

      route(/^(?:youtube|yt)(?: me)?\s+(.*)/i, :find_video, command: true, help: {
        "youtube (me) QUERY" => "Gets a YouTube video."
      })
      # Detect YouTube links in non-commands and display video info
      route(/\byoutube\.com\/watch\?v=([^?&#\s]+)/i, :display_info, command: false)
      route(/\byoutu\.be\/([^?&#\s]+)/i, :display_info, command: false)

      def find_video(response)
        query = response.matches[0][0]
        http_response = http.get(
          "#{API_URL}/search",
          q: query,
          order: "relevance",
          maxResults: 15,
          part: "snippet",
          key: config.api_key
        )
        return if http_response.status != 200
        videos = MultiJson.load(http_response.body)["items"]
        video = config.top_result ? videos.first : videos.sample
        id = video["id"]["videoId"]
        response.reply "https://www.youtube.com/watch?v=#{id}"
        if config.video_info
          response.reply info(id)
        end
      end

      def display_info(response)
        if config.detect_urls
          id = response.matches[0][0]
          info_string = info(id)
          unless info_string.nil?
            response.reply info_string
          end
        end
      end

      def info(id)
        http_response = http.get(
          "#{API_URL}/videos",
          id: id,
          part: "contentDetails,snippet,statistics",
          key: config.api_key
        )
        return nil if http_response.status != 200
        videos = MultiJson.load(http_response.body)["items"]
        return nil if videos.empty?
        video = videos[0]
        title = video["snippet"]["title"]
        uploader = video["snippet"]["channelTitle"]
        date = DateTime.iso8601(video["snippet"]["publishedAt"]).strftime("%F")

        # Format time, only show hours if necessary
        duration = ISO8601::Duration.new(video["contentDetails"]["duration"])
        sec = duration.to_seconds.to_i
        min = sec / 60
        hr = min / 60
        time = "%d:%02d" % [min, sec%60]
        if hr > 0
          time = "%d:%02d:%02d" % [hr, min%60, sec%60]
        end

        # Abbreviate view count, based on http://stackoverflow.com/a/2693484
        n = video["statistics"]["viewCount"].to_i
        i = 0
        while n >= 1e3 do
          n /= 1e3
          i += 1
        end
        views = "%.#{n.to_s.length>3?1:0}f%s" % [n.round(1), " kMBT"[i]]

        # Calculate rating percentage
        likes = video["statistics"]["likeCount"].to_f
        dislikes = video["statistics"]["dislikeCount"].to_f
        rating = "%.f" % (likes / (likes + dislikes) * 100)

        "#{title} [#{time}] by #{uploader} on #{date} (#{views.strip} views, #{rating}% liked)"
      end
    end

    Lita.register_handler(YoutubeMe)
  end
end
