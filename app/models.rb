require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection ENV['DATABASE_URL'] || "mysql://root:root@localhost/hoipolloi_development"

class User < ActiveRecord::Base
  has_many :tweets
end

class Conversation < ActiveRecord::Base
  EMOJI = %w(e001 e002 e003 e004 e005 e006 e007 e008 e009 e00a e00b e00c e00d e00e e00f e010 e011 e012 e013 e014 e015 e016 e017 e018 e019 e01a e01b e01c e01d e01e e01f e020 e021 e022 e023 e024 e025 e026 e027 e028 e029 e02a e02b e02c e02d e02e e02f e030 e031 e032 e033 e034 e035 e036 e037 e038 e039 e03a e03b e03c e03d e03e e03f e040 e041 e042 e043 e044 e045 e046 e047 e048 e049 e04a e04b e04c e04d e04e e04f e050 e051 e052 e053 e054 e055 e056 e057 e058 e059 e05a e101 e102 e103 e104 e105 e106 e107 e108 e109 e10a e10b e10c e10d e10e e10f e110 e111 e112 e113 e114 e115 e116 e117 e118 e119 e11a e11b e11c e11d e11e e11f e120 e121 e122 e123 e124 e125 e126 e127 e128 e129 e12a e12b e12c e12d e12e e12f e130 e131 e132 e133 e134 e135 e136 e137 e138 e139 e13a e13b e13c e13d e13e e13f e140 e141 e142 e143 e144 e145 e146 e147 e148 e149 e14a e14b e14c e14d e14e e14f e150 e151 e152 e153 e154 e155 e156 e157 e158 e159 e15a e201 e202 e203 e204 e205 e206 e207 e208 e209 e20a e20b e20c e20d e20e e20f e210 e211 e212 e213 e214 e215 e216 e217 e218 e219 e21a e21b e21c e21d e21e e21f e220 e221 e222 e223 e224 e225 e226 e227 e228 e229 e22a e22b e22c e22d e22e e22f e230 e231 e232 e233 e234 e235 e236 e237 e238 e239 e23a e23b e23c e23d e23e e23f e240 e241 e242 e243 e244 e245 e246 e247 e248 e249 e24a e24b e24c e24d e24e e24f e250 e251 e252 e253 e301 e302 e303 e304 e305 e306 e307 e308 e309 e30a e30b e30c e30d e30e e30f e310 e311 e312 e313 e314 e315 e316 e317 e318 e319 e31a e31b e31c e31d e31e e31f e320 e321 e322 e323 e324 e325 e326 e327 e328 e329 e32a e32b e32c e32d e32e e32f e330 e331 e332 e333 e334 e335 e336 e337 e338 e339 e33a e33b e33c e33d e33e e33f e340 e341 e342 e343 e344 e345 e346 e347 e348 e349 e34a e34b e34c e34d e401 e402 e403 e404 e405 e406 e407 e408 e409 e40a e40b e40c e40d e40e e40f e410 e411 e412 e413 e414 e415 e416 e417 e418 e419 e41a e41b e41c e41d e41e e41f e420 e421 e422 e423 e424 e425 e426 e427 e428 e429 e42a e42b e42c e42d e42e e42f e430 e431 e432 e433 e434 e435 e436 e437 e438 e439 e43a e43b e43c e43d e43e e43f e440 e441 e442 e443 e444 e445 e446 e447 e448 e449 e44a e44b e44c e501 e502 e503 e504 e505 e506 e507 e508 e509 e50a e50b e50c e50d e50e e50f e510 e511 e512 e513 e514 e515 e516 e517 e518 e519 e51a e51b e51c e51d e51e e51f e520 e521 e522 e523 e524 e525 e526 e527 e528 e529 e52a e52b e52c e52d e52e e52f e530 e531 e532 e533 e534 e535 e536 e537)

  belongs_to :user
  has_many :tweets

  class << self
    # There's gotta be a better way of doing this...
    def recent_conversations limit, current_user, newer_than = false
      scope = self.order('(SELECT tweeted_at FROM tweets WHERE (conversations.id=tweets.conversation_id) ORDER BY tweeted_at DESC LIMIT 1) DESC')
                  .limit(10)
                  .includes(:tweets)
                  .where("tweets.from_name != '#{current_user}'")
      
      if newer_than
        scope = scope.where("conversations.created_at > '#{newer_than || '0000-00-00 00:00:00'}'")
      end

      scope.all
    end

    def most_recent_conversation
      self.order('created_at DESC').limit(1).first
    end
  end

  def from_names(current_user)
    get_from_names(current_user).to_sentence
  end

  def from_names_at(current_user)
    get_from_names(current_user).map { |n| "@#{n}" }.join(' ')
  end

  def snippet
    tweets.order('tweeted_at DESC').first.text
  end

  def output_text
    Conversation::EMOJI.each do |emoji|
      text.gsub! "\u" + emoji, "<i class='emoji emoji_#{emoji}'></i>"
    end
    
    text
  end

  private

  def get_from_names(current_user)
    tweets.where("tweets.from_name != '#{current_user}'").map(&:from_name).uniq
  end
end

class Tweet < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
end