![Hoi Polloi!](http://f.cl.ly/items/2n0V3N3h0J3k2c3K1F1h/Screen%20Shot%202012-02-29%20at%2000.01.46.png)

## Treat your tweets like an inbox

[Hoi Polloi!](http://hoipolloi.heroku.com) is a small Twitter client that regularly reads in your tweets and mentions and generates conversations. It allows you to keep track of what mentions you've replied to and what conversations you're having.

**It's pretty basic and slow right now, so I wouldn't recommend it for serious use. I'm working improving the code base, adding some tests and expanding the functionality. Additionally, the conversation generation engine is a little funky.**

### What It Does

* Pulls in tweets and mentions
* Organises tweets by conversation
* Intelligent conversation 'reading'
* Inline reply

### What It Will Do

* Entire back-catalogue of tweets
* Searching
* Starred tweets (maybe linking in with favourites?)
* Pagination
* Exposing the tweets as an SMTP server for use with a real mail client
* API
* Tags/categories

### The Tech

Currently, Hoi Polloi! is written with:

* Ruby 1.9.2
* Sinatra 1.3.2
* MySQL 5.5.15

However, I'm seriously rethinking using MySQL, in favour of MongoDB. I'm umming and ahhing about the best way to store the large amounts of data that accrue with using this app.

### How to get it running locally

Clone the repository and change into the directory. Make sure you add your database connection DSN string, and your Twitter API consumer token and secret as environment variables:

	$ export DATABASE_URL=mysql://root@localhost/hoipolloi_development
	$ export TWITTER_CONSUMER_KEY=blah
	$ export TWITTER_CONSUMER_SECRET=blah

Set up the environment with Bundler:

	$ bundle install

And rack it up!

	$ bundle exec rackup config.ru

### What's the name about?

Hoi polloi is a wonderful gem I discovered in the English lexicon describing, in plural, the masses, the people, *les gens*. The exclamation point is there because exclamation points are awesome.