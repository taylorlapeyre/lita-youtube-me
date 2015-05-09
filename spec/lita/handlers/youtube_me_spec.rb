require "spec_helper"

describe Lita::Handlers::YoutubeMe, lita_handler: true do
  before do
    registry.config.handlers.youtube_me.api_key = ENV["YOUTUBE_KEY"]
  end

  it { is_expected.to route_command("youtube me something") }
  it { is_expected.to route_command("youtube me something").to(:find_video) }

  it { is_expected.to route_command("youtube something") }
  it { is_expected.to route_command("youtube something").to(:find_video) }

  it { is_expected.to route_command("yt me something") }
  it { is_expected.to route_command("yt me something").to(:find_video) }

  it { is_expected.to route_command("yt something") }
  it { is_expected.to route_command("yt something").to(:find_video) }

  it { is_expected.to route("https://www.youtube.com/watch?v=nG7RiygTwR4&feature=youtube_gdata") }
  it { is_expected.to route("https://www.youtube.com/watch?v=nG7RiygTwR4&feature=youtube_gdata").to(:display_info) }

  it { is_expected.to route("taco https://youtu.be/nG7RiygTwR4?t=9m13s taco") }
  it { is_expected.to route("taco https://youtu.be/nG7RiygTwR4?t=9m13s taco").to(:display_info) }

  it "can find a youtube video with a query" do
    send_command("youtube me soccer")
    expect(replies.count).to eq 1
    expect(replies.last).to_not be_nil
    expect(replies.last).to match(/youtube\.com/)
  end

  it "displays info for a requested video when the video_info config variable is true" do
    registry.config.handlers.youtube_me.video_info = true
    send_command("yt soccer")
    expect(replies.count).to eq 2
    expect(replies.first).to_not be_nil
    expect(replies.first).to match(/youtube\.com/)
    expect(replies.last).to_not be_nil
    expect(replies.last).to match(/views/)
  end

  it "does not display info for a requested video when the video_info config variable is false" do
    registry.config.handlers.youtube_me.video_info = false
    send_command("youtube me soccer")
    expect(replies.count).to eq 1
    expect(replies.last).to_not be_nil
    expect(replies.last).to match(/youtube\.com/)
  end

  it "displays video info for detected YouTube URLs when the detect_urls config variable is true" do
    registry.config.handlers.youtube_me.detect_urls = true
    send_message("taco taco https://www.youtube.com/watch?v=nG7RiygTwR4 taco taco")
    expect(replies.count).to eq 1
    expect(replies.first).to_not be_nil
    expect(replies.first).to match(/10 minutes of DJ Mbenga saying Tacos \[10:02\] by RickFreeloader on 2011-09-12 \(\S+ views, \d+% liked\)/)
  end

  it "does not display video info for detected YouTube URLs when the detect_urls config variable is false" do
    registry.config.handlers.youtube_me.detect_urls = false
    send_message("https://www.youtube.com/watch?v=nG7RiygTwR4")
    expect(replies.count).to eq 0
  end

  it "does not send a message when the detected YouTube URL does not lead to a valid video" do
    registry.config.handlers.youtube_me.detect_urls = true
    send_message("https://www.youtube.com/watch?v=foo")
    expect(replies.count).to eq 0
  end

  it "does not return a video in response to a query when the API key is invalid" do
    registry.config.handlers.youtube_me.api_key = "this key doesn't work"
    send_command("youtube me soccer")
    expect(replies.count).to eq 0
  end

  it "does not display video info for detected YouTube URLs when the API key is invalid" do
    registry.config.handlers.youtube_me.detect_urls = true
    registry.config.handlers.youtube_me.api_key = "this key doesn't work"
    send_message("https://www.youtube.com/watch?v=nG7RiygTwR4")
    expect(replies.count).to eq 0
  end
end
