require 'spec_helper'

module SafeRedirect
  describe SafeRedirect do
    class Controller
      extend SafeRedirect
    end
  
    before(:all) do
      load_config
    end

    it "considers https://www.bukalapak.com a safe domain" do
      expect(Controller.safe_domain?('https://www.bukalapak.com')).to eq(true)
    end

    it "considers / a safe domain" do
      expect(Controller.safe_domain?('/')).to eq(true)
    end

    it "considers // an unsafe domain" do
      expect(Controller.safe_domain?('//')).to eq(false)
    end

    it "considers http://www.twitter.com a safe domain" do
      expect(Controller.safe_domain?('http://www.twitter.com')).to eq(true)
    end

    it "considers https://www.bukalapak.com@google.com an unsafe domain" do
      expect(Controller.safe_domain?('https://www.bukalapak.com@google.com')).to eq(false)
    end

    it "considers https://www.bukalapak.com a safe path" do
      expect(Controller.safe_path('https://www.bukalapak.com')).to eq('https://www.bukalapak.com')
    end

    it "considers / a safe path" do
      expect(Controller.safe_path('/')).to eq('/')
    end

    it "considers // an unsafe path" do
      expect(Controller.safe_path('//')).to eq('')
    end

    it "considers http://www.twitter.com a safe path" do
      expect(Controller.safe_path('http://www.twitter.com')).to eq('http://www.twitter.com')
    end

    it "considers https://www.bukalapak.com@google.com an unsafe path" do
      expect(Controller.safe_path('https://www.bukalapak.com@google.com')).to eq('')
    end
  end
end