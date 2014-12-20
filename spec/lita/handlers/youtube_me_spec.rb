require "spec_helper"

describe Lita::Handlers::YoutubeMe, lita_handler: true do
  it { is_expected.to route_command("youtube me something") }
  it { is_expected.to route_command("youtube me something").to(:find_video) }

  it { is_expected.to route_command("youtube something") }
  it { is_expected.to route_command("youtube something").to(:find_video) }

  it "can find a youtube video with a query" do
    send_command("youtube me soccer")
    expect(replies.count).to eq 1
    expect(replies.last).to_not be_nil
    expect(replies.last).to match(/youtube\.com/)
  end
end
