---
title: Third Party Integrations
layout: gem-single
name: dry-monitor
---

### Shrine

[Shrine](https://shrine.io) is a Ruby gem that provides a simple, declarative way to build file uploaders. You can instrument your uploaders with `dry-monitor` to get a detailed log of all the files that are uploaded.

For more information, please visit the [official Shrine documentation](https://shrinerb.com/docs/plugins/instrumentation).

```ruby
require 'shrine'
require 'dry-monitor'

Shrine.plugin :instrumentation, monitor: Dry::Monitor::Notifications.new(:my_app)
```

### GraphQL

You can easily instrument GraphQL applications with `dry-monitor` with a simple custom tracer.

```ruby
require 'dry/system/container'

# system/boot/container.rb
class App < Dry::System::Container
  use :notifications
end

# app/my_schema.rb
class MySchema < GraphQL::Schema
  tracer GraphQL::Tracing::NotificationsTracing.new(App[:notifications])
end
```
