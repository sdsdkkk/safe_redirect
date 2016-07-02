require 'spec_helper'

module SafeRedirect
  describe SafeRedirect do
    class Controller
      extend SafeRedirect
    end
  
    before(:all) do
      load_config
    end

    SAFE_PATHS = [
      'https://www.bukalapak.com',
      '/',
      'http://www.twitter.com',
      :back,
      {controller: 'home', action: 'index'}
    ]

    UNSAFE_PATHS = %w(// https://www.bukalapak.com@google.com http://////@@@@@@attacker.com//evil.com
                      .@@@google.com //bukalapak.com%25%40%25%40%25%40%25%40%25%40%25%40%25%40evil.com
                      %25%40%25%40%25%40%25%40%25%40%25%40%25%40%25%40%25%40%25%40evil.com 
                      %@%@%@%@%@%@%@%@%@%@evil.com https://www-bukalapak.com)

    SAFE_PATHS.each do |path|
      it "considers #{path} a safe path" do
        expect(Controller.safe_path(path)).to eq(path)
      end
    end

    UNSAFE_PATHS.each do |path|
      it "considers #{path} an unsafe path" do
        expect(Controller.safe_path(path)).to eq('/')
      end
    end

    it "can use redirect_to method with only the target path" do
      Controller.redirect_to '/'
    end

    it "can use redirect_to method with both the target path and the options" do
      Controller.redirect_to '/', notice: 'Back to home page'
    end
  end
end
