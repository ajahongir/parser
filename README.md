#ruby-1.9.3-p392
#rails '3.2.12'
#DB - sqligh НО можно использовать другие БД.

bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rspec spec
bundle exec rails s