# A user that has signed up for the site
class User < ActiveRecord::Base
  has_many :tweets
end
