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
      expect(Controller.safe_path('//')).to eq('/')
    end

    it "considers http://www.twitter.com a safe path" do
      expect(Controller.safe_path('http://www.twitter.com')).to eq('http://www.twitter.com')
    end

    it "considers :back a safe path" do
      expect(Controller.safe_path(:back)).to eq(:back)
    end

    it "considers {controller: 'home', action: 'index'} a safe path" do
      expect(Controller.safe_path({controller: 'home', action: 'index'})).to eq({controller: 'home', action: 'index'})
    end

    it "considers https://www.bukalapak.com@google.com an unsafe path" do
      expect(Controller.safe_path('https://www.bukalapak.com@google.com')).to eq('/')
    end

    it "considers .@@@google.com an unsafe path" do
      expect(Controller.safe_path('.@@@google.com')).to eq('/')
      expect(Controller.safe_path('.@@@google.com/search')).to eq('/search')
    end

    it "can use redirect_to method with only the target path" do
      Controller.redirect_to '/'
    end

    it "can use redirect_to method with both the target path and the options" do
      Controller.redirect_to '/', notice: 'Back to home page'
    end
  end
end
