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
require 'dry-monitor'

$notifications = Dry::Monitor::Notifications.new(:my_app)
$notifications.register_event(:graphql)

class DryTracer
  def self.trace(key, metadata)
    payload = { event_name: event_name, **metadata }

    $notifications.instrument(:graphql, payload) { yield }
  end
end

class MySchema < GraphQL::Schema
  tracer(DryTracer)
end
```