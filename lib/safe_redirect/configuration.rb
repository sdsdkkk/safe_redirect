module SafeRedirect
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  class Configuration
    attr_accessor :default_path, :whitelist_local
    attr_reader :domain_whitelists

    def initialize
      self.default_path = '/'
      self.whitelist_local = false
      self.domain_whitelists = []
    end

    def domain_whitelists=(whitelists)
      if whitelists.any?{ |w| w =~ /\*\z/ }
        raise ArgumentError, "whitelisted domain cannot end with a glob (*)"
      end

      @domain_whitelists = whitelists
    end
  end
end