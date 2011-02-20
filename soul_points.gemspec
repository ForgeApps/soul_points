$:.unshift File.expand_path("../lib", __FILE__)
require "soul_points/version"

Gem::Specification.new do |gem|
  gem.name    = "soul_points"
  gem.version = SoulPoints::VERSION

  gem.author      = "Forge Apps"
  gem.email       = "support@mysoulpoints.com"
  gem.homepage    = "http://mysoulpoints.com/"
  gem.summary     = "Client library and CLI to the mysoulpoints.com API."
  gem.description = "Client library and CLI to the mysoulpoints.com API."
  gem.executables = "soul_points"

  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }

  #gem.add_development_dependency "fakefs",  "~> 0.3.1"
  #gem.add_development_dependency "rake"
  #gem.add_development_dependency "rspec",   "~> 1.3.0"
  #gem.add_development_dependency "taps",    "~> 0.3.11"
  #gem.add_development_dependency "webmock", "~> 1.5.0"

  gem.add_dependency "rest-client"
  gem.add_dependency "json"
end
