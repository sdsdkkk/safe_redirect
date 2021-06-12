require 'rubygems'
require 'rspec'

require File.join(File.dirname(__FILE__), '..', 'lib', 'safe_redirect')

def reset_config
  SafeRedirect.reset_config
end

def load_config(whitelist_local = false)
  SafeRedirect.configure do |config|
    config.default_path = '/sdsdkkk'
    config.domain_whitelists = %w{http://www.twitter.com https://www.bukalapak.com http://*.foo.org https://*.test.com/good-end-point}
    config.whitelist_local = whitelist_local
  end
end

module SafeRedirect
  class << self
    def reset_config
      @configuration = Configuration.new
    end
  end
end