require 'twitter'

module TwitterRaper
  class Client
    def initialize(username)
      p Twitter.user(username)
    end
  end
end