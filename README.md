# EEE

EEE stands for [Easy Event Exchange][eee] which is an open network
protocol for exchange of calendar data. The protocol specifies
communication between client and server and servers themselves. It
also has additional support for scheduling and server administration.

This Ruby Gem implements both ESClient (server to client) and ESServer
(server to server) method calls. Additionally, convenient scenario
runner (making multiple method calls using one TCP channel) and test
helpers are provided.

Although this Gem follows the EEE specification, it does provides
additional comfort. Many "get" methods expect query parameter to be
passed. This parameter can be empty string which is often what is
passed. Therefore, this Gem doesn't require client code to explicitly
pass query as empty string and makes it default.

TODO: This Gem is not complete, most significantly these parts:
- event manipulation methods (rely on [RiCal][] which is not complete
  itself)
- service discovery

## Installation

Add this line to your application's Gemfile:

    gem 'eee'

And then execute:

    $ bundle

## Usage

This is typical sequence to connect to EEE server as client:

```ruby
eee_server = Scenario.new Methods::Client.new,
  host: zonio.net
  port: 4446
eee_server.append_call :authenticate,
  'filip.zrust@zonio.net', 'p4ssw0rd'
eee_server.append_call :get_calendars
ok, response = eee_server.send
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[eee]: http://zonio.net/confluence/display/3E/Easy+Event+Exchange+protocol+specification "Easy Event Exchange protocol specification"
[rical]: http://ri-cal.rubyforge.org "iCalendar for Ruby"
