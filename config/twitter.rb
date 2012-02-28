module HoiPolloi
  def self.configuration
    {
      :consumer_key => ENV['TWITTER_CONSUMER_KEY'],
      :consumer_secret => ENV['TWITTER_CONSUMER_SECRET']
    }
  end
end