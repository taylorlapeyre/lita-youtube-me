require "date"

module Lita
  module Handlers
    class YoutubeMe < Handler
      API_URL = "https://gdata.youtube.com/feeds/api/videos"

      config :video_info, types: [TrueClass, FalseClass], default: false
      config :detect_urls, types: [TrueClass, FalseClass], default: false

      route(/^(?:youtube|yt)(?: me)?\s+(.*)/i, :find_video, command: true, help: {
        "youtube (me) QUERY" => "Gets a youtube video."
      })
      # Detect YouTube links in non-commands and display video info
      route(/\byoutube\.com\/watch\?v=([^?&#\s]+)/i, :display_info, command: false)
      route(/\byoutu\.be\/([^?&#\s]+)/i, :display_info, command: false)

      def find_video(response)
        query = response.matches[0][0]
        http_response = http.get(API_URL,
          q: query,
          orderBy: "relevance",
          "max-results" => 15,
          alt: "json"
        )
        videos = MultiJson.load(http_response.body)["feed"]["entry"]
        video = videos.sample
        video["link"].each do |link|
          if link["rel"] == "alternate" && link["type"] == "text/html"
            response.reply link["href"].split("&").first
          end
        end
        if config.video_info
          response.reply info(video)
        end
      end

      def display_info(response)
        if config.detect_urls
          id = response.matches[0][0]
          http_response = http.get("#{API_URL}/#{id}", alt: "json")
          video = MultiJson.load(http_response.body)["entry"]
          response.reply info(video)
        end
      end

      def info(video)
        title = video["title"]["$t"]
        uploader = video["author"][0]["name"]["$t"]
        date = DateTime.iso8601(video["published"]["$t"]).strftime("%F")

        # Format time, only show hours if necessary
        sec = video["media$group"]["yt$duration"]["seconds"].to_i
        min = sec / 60
        hr = min / 60
        time = "%d:%02d" % [min, sec%60]
        if hr > 0
          time = "%d:%02d:%02d" % [hr, min%60, sec%60]
        end

        # Abbreviate view count, based on http://stackoverflow.com/a/2693484
        n = video["yt$statistics"]["viewCount"].to_i
        i = 0
        while n >= 1e3 do
          n /= 1e3
          i += 1
        end
        views = "%.#{n.to_s.length>3?1:0}f%s" % [n.round(1), " kMBT"[i]]

        # Calculate rating, accounting for YouTube's 1-5 score range
        rating = "%.f" % [(video.fetch("gd$rating", {}).fetch("average", 1) - 1) / 4 * 100]

        "#{title} [#{time}] by #{uploader} on #{date} (#{views.strip} views, #{rating}% liked)"
      end
    end

    Lita.register_handler(YoutubeMe)
  end
end
