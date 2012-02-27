require 'twitter'

module TwitterRaper
  class Client
    def initialize context
      @context = context
    end

    def rape
      current_tweet = User.all :uid => @context.current_user.id
      mentions = @context.mentions
    end
  end
end