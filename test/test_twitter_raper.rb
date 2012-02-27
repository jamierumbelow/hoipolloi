require './test/test_helper'

module TwitterRaper
  class TestClient < MiniTest::Unit::TestCase
    def test_rape
      twitter_mock = MiniTest::Mock.new
      user_mock = MiniTest::Mock.new

      client = Client.new twitter_mock

      user_mock.expect :id, 1

      twitter_mock.expect :mentions, {}
      twitter_mock.expect :current_user, user_mock

      ::User.expects(:all).with(:uid => 1)

      client.rape

      user_mock.verify
      twitter_mock.verify
    end
  end
end