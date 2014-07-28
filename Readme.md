## HSR Realtime Map

    $ bundle install
    $ rake db:create
    $ rake db:schema:load
    $ cp config/config.sample.yml config/config.yml

Sign up for a [MapBox](https://www.mapbox.com/) account, if you do not already have one. Update `config.yml` with your `MapboxId`.

    $ ruby app.rb