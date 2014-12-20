require 'pry'

module Lita
  module Handlers
    class Youtube < Handler
      API_URL = "https://gdata.youtube.com/feeds/api/videos"

      route(/youtube( me)? (.*)/i, :find_video, command: true, help: {
        "youtube (me) QUERY" => "Gets a youtube video."
      })

      def find_video(response)
        query = response.matches[0][1]
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
            response.reply link["href"]
          end
        end
      end
    end

    Lita.register_handler(Youtube)
  end
end
