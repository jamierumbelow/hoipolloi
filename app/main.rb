require 'bundler/setup'

require 'sinatra'
require 'twitter_oauth'

require './config/twitter'

module HoiPolloi
  class App < Sinatra::Base
    set :root, Proc.new { File.expand_path File.join(File.dirname(__FILE__), '../') }
    set :views, Proc.new { File.join root, 'app/views' }

    before do
      @client = ::TwitterOAuth::Client.new(
        :consumer_key => HoiPolloi.configuration[:consumer_key],
        :consumer_secret => HoiPolloi.configuration[:consumer_secret],
      )
    end

    get '/' do
      erb :index
    end

    get '/twitter/connect' do

    end
  end
end