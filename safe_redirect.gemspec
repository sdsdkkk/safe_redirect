
# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safe_redirect/version'

Gem::Specification.new do |gem|
  gem.name          = "safe_redirect"
  gem.version       = SafeRedirect::VERSION
  gem.authors       = ["Edwin Tunggawan"]
  gem.email         = ["vcc.edwint@gmail.com"]
  gem.description   = %q{Preventing open redirects in Rails apps}
  gem.summary       = %q{Preventing open redirects in Rails apps}
  gem.homepage      = "https://github.com/sdsdkkk/safe_redirect"
  gem.licenses      = ['MIT']

  gem.add_development_dependency 'rspec'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib", "lib/safe_redirect"]
end