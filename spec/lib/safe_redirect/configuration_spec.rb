require 'spec_helper'

module SafeRedirect
  describe Configuration do
    before(:each) do
      reset_config
    end

    it 'errors if you try to end whitelisted domain with glob' do
      config_update = -> do
        SafeRedirect.configure do |config|
          config.domain_whitelists = ["foo.*"]
        end
      end

      expect(config_update).to raise_error(ArgumentError)
    end

    it 'default default_path is /' do
      expect(SafeRedirect.configuration.default_path).to eq('/')
    end

    it 'default domain_whitelists is []' do
      expect(SafeRedirect.configuration.domain_whitelists).to eq([])
    end

    it 'can update default_path' do
      SafeRedirect.configure do |config|
        config.default_path = 'https://www.bukalapak.com'
      end
      expect(SafeRedirect.configuration.default_path).to eq('https://www.bukalapak.com')
    end

    it 'can update domain_whitelists' do
      SafeRedirect.configure do |config|
        config.domain_whitelists = ['www.bukalapak.com']
      end
      expect(SafeRedirect.configuration.domain_whitelists).to eq(['www.bukalapak.com'])
    end
  end
end
