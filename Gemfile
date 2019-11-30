# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'dry-events', github: 'dry-rb/dry-events', branch: 'master'

group :test do
  gem 'rack'
  gem 'simplecov', platform: :mri, require: false
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'ossy', github: 'solnic/ossy', branch: 'master'
end
