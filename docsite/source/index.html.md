---
title: Introduction
layout: gem-single
name: dry-monitor
type: gem
sections:
  - third-party-integrations
---

This gem provides monitoring and instrumentation APIs for Ruby. The instrumentation API allows you to measure how certain actions are carried out within Ruby code, such as in a web application or a third-party gem. It is not coupled with any framework and is easy to integrate into any application.

It does a couple of things for you:

- Ability to subscribe and publish event notifications
- Has an interface compatible with [`ActiveSupport::Notifications`](https://guides.rubyonrails.org/active_support_instrumentation.html) for easy integration with other frameworks
- Plugins to monitor SQL queries, HTTP requests, and others

### Basic Usage

```ruby
require 'dry-monitor'

notifications = Dry::Monitor::Notifications.new(:my_app).tap do |n|
  n.register_event('component.render')
end

logger = Logger.new(STDOUT)

notifications.subscribe('component.render') do |event|
  logger.info "Component rendered: #{event.payload}"
end

notifications.instrument('component.render', component_name: 'TestComponent') { sleep 0.2 }

# => INFO -- : Component rendered: {:component_name=>"TestComponent", :time=>201}
```