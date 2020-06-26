# Activerecord::Jdbcvertica::Adapter
ActiveRecord adapter for Vertica databases that works on JRuby with Vertica JDBC adapter

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-jdbcvertica-adapter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-jdbcvertica-adapter

## Usage

### Unit Tests

1. Run a local Vertica instance via Docker Compose
   1. Create a directory (e.g. `vertica`) and create a `docker-compose.yml` file with the following contents

```yml
# docker-compose.yml

version: "3"
services:
  db:
    image: jbfavre/vertica:latest
    environment:
      - DATABASE_ADAPTER=vertica5
      - DATABASE_USERNAME=dbadmin
      - DATABASE_NAME=docker
      - DATABASE_HOST=127.0.0.1
      - DATABASE_PORT=5433
    ports:
      - "5433:5433"
```

2. Run `docker-compose up`
3. Switch to the `activerecord-jdbcvertica-adapter` project directory
4. Run `rake` to run the tests

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
