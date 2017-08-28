# v0.0.3 2017-08-28

### Changed

* Update default theme setting for compatibility with latest version of rouge (alexandru-calinoiu)
* Require latest version of rouge gem (timriley)

# v0.0.2 2017-02-02

### Added

* `Dry::Monitor::Rack::Middleware#on` shortcut (solnic)
* `Dry::Monitor::Rack::Middleware#instrument` shortcut (solnic)
* `Dry::Monitor::SQL::Logger` can be configured with a custom message template (solnic)

### Changed

* `Dry::Monitor::Rack::Logger#{subscribe=>attach}` and now it accepts a rack middleware instance (solnic)
* `Dry::Monitor::Rack::Logger` appends new lines when logging `:rack.request.stop` events (solnic)

# v0.0.1 2017-02-01

First public release
