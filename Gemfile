# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-core", github: "dry-rb/dry-core", branch: "main"
gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-events", github: "dry-rb/dry-events", branch: "main"

group :test do
  gem "rack"
end

group :tools do
  gem "byebug", platform: :mri
end
