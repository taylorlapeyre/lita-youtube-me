# lita-youtube-me

Replies with a video that matches a string. Optionally detects YouTube URLs and returns title, duration, etc.

## Installation

Add lita-youtube to your Lita instance's Gemfile:

``` ruby
gem "lita-youtube-me"
```

## Configuration

This plugin requires an API key for the [YouTube Data API (v3)](https://developers.google.com/youtube/v3/).

``` ruby
Lita.configure do |config|
  config.handlers.youtube_me.api_key = "FooBarBazLuhrmann"
end
```

### Optional attributes
* `video_info` (boolean) - When set to `true`, Lita will return additional information (title, duration, etc.) about the video. Default: `false`
* `detect_urls` (boolean) - When set to `true`, Lita will return additional information about any YouTube URLs it detects. Default: `false`

``` ruby
Lita.configure do |config|
  config.handlers.youtube_me.video_info = true
  config.handlers.youtube_me.detect_urls = true
end
```

## Usage

The following are all equivalent ways of asking Lita to search for a video about "soccer":
```
@bot: youtube me soccer
@bot: youtube soccer
@bot: yt me soccer
@bot: yt soccer
```

Lita's default response will be a YouTube URL:
```
<bot> https://www.youtube.com/watch?v=SZJldG6bP1s
```

Enabling the config variable `video_info` will add another line to Lita's response:
```
<bot> https://www.youtube.com/watch?v=SZJldG6bP1s
<bot> Soccer Kid Thug [0:23] by turdmalone on 2015-04-10 (49.5k views, 96% liked)
```

Enabling `detect_urls` will make Lita return information about any YouTube URLs it detects:
```
<jack> hey @jill check out the new game of thrones trailer https://www.youtube.com/watch?v=dQw4w9WgXcQ lol
<bot> Rick Astley - Never Gonna Give You Up [3:33] by RickAstleyVEVO on 2009-10-25 (115.2M views, 94% liked)
<jill> nope, not falling for it this time!
<jack> drat
```

## License

[MIT](http://opensource.org/licenses/MIT)
