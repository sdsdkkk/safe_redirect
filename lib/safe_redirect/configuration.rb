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
    attr_accessor :default_path, :domain_whitelists

    def initialize
      self.default_path = '/'
      self.domain_whitelists = []
    end
  end
end