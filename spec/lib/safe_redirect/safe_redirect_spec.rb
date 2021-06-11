require 'spec_helper'
require 'stringio'
require 'logger'
require 'pry'

module SafeRedirect
  describe SafeRedirect do
    class BaseController
      def redirect_to(*)
        # test stub
      end
    end

    class Controller < BaseController
      extend SafeRedirect
    end

    SAFE_PATHS = [
      'https://www.bukalapak.com',
      '/',
      '/foobar',
      'http://www.twitter.com',
      'http://blah.foo.org',
      'http://bl-ah.foo.org',
      'http://foo.org',
      'http://foo.org/',
      :back,
      ['some', 'object'],
      { controller: 'home', action: 'index' },
    ]

    UNSAFE_PATHS = [
      "https://www.bukalapak.com@google.com",
      "http://////@@@@@@attacker.com//evil.com",
      "//bukalapak.com%25%40%25%40%25%40%25%40%25%40%25%40%25%40evil.com",
      "evil.com",
      ".evil.com",
      "%@%@%@%@%@%@%@%@%@%@evil.com",
      "https://www-bukalapak.com",
      "https://www.bukalapak.com\n.evil.com",
      "http://blah.blah.foo.org",
      "///bit.ly/1hqE77G",
    ]

    shared_examples_for 'nonlocal hosts' do
      SAFE_PATHS.each do |path|
        it "considers #{path} a safe path" do
          expect(Controller.safe_path(path)).to eq(path)
        end
      end

      UNSAFE_PATHS.each do |path|
        it "considers #{path} an unsafe path" do
          expect(Controller.safe_path(path)).to eq(SafeRedirect.configuration.default_path)
        end
      end

      it 'filters host, port, and protocol options when hash is passed to safe_path' do
        hash = { host: 'yahoo.com', port: 80, protocol: 'https', controller: 'home', action: 'index' }
        safe_hash = { port: 80, protocol: 'https', controller: 'home', action: 'index' }
        expect(Controller.safe_path(hash)).to eq(safe_hash)
      end

      it 'can use redirect_to method with only the target path' do
        Controller.redirect_to '/'
      end

      it 'can use redirect_to method with both the target path and the options' do
        Controller.redirect_to '/', notice: 'Back to home page'
      end

      it 'can log violations' do
        log_io = StringIO.new
        SafeRedirect.configure{ |config| config.log = Logger.new(log_io) }

        Controller.redirect_to(UNSAFE_PATHS.first)

        expect(log_io.size).not_to eq(0)
      end
    end

    context 'whitelist_local is not set' do

      before(:all) do
        load_config
      end

      it_should_behave_like 'nonlocal hosts'

      it 'considers local addresses as unsafe' do
        path = 'http://127.0.0.1'
        expect(Controller.safe_path(path)).to eq(SafeRedirect.configuration.default_path)
      end
    end

    context 'whitelist_local is set' do

      before(:all) do
        load_config true
      end

      it_should_behave_like 'nonlocal hosts'

      it 'considers local addresses as safe' do
        path = 'http://127.0.0.1'
        expect(Controller.safe_path(path)).to eq(path)
      end
    end

    describe "#safe_domain?" do
      let(:allowlist) do
        [
          'https://www.bukalapak.com',
          'https://www.bar.foo.com/path',
          'https://documents.foo.com/access/jwt',
          'https://*.foo.com',
          'https://*.test.com/good-end-point'
        ]
      end

      before do
        allow(SafeRedirect.configuration).to receive(:domain_whitelists).and_return(allowlist)
      end
      
      it "allows domains in the allowlist", :aggregate_failures do
        expect(Controller.safe_domain?(URI('https://www.bukalapak.com'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://www.bar.foo.com/path'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://documents.foo.com/access/jwt'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://good.foo.com'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://us.test.com/good-end-point'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://us.test.com/good-end-point/password=123'))).to be_truthy
      end

      it "allows domains with or without trailing slash" do
        expect(Controller.safe_domain?(URI('https://www.bukalapak.com'))).to be_truthy
        expect(Controller.safe_domain?(URI('https://www.bukalapak.com/'))).to be_truthy
      end
      
      it "allows domains that start with an allowed domain" do
        expect(Controller.safe_domain?(URI('https://www.bukalapak.com/path'))).to be_truthy
      end

      it "disallows the domains not in the allowlist" do
        expect(Controller.safe_domain?(URI('https://www.evil.com'))).to be_falsey
      end

      it "disallows domains that include url components not in the allowlist, wildcard included" do
        expect(Controller.safe_domain?(URI("https://test.com/evil-endpoint/password=hahaha"))).to be_falsey
        expect(Controller.safe_domain?(URI("https://good-website.test.com/evil-endpoint"))).to be_falsey
      end

      it "disallows domains that include a domain from the allowlist as part of the url", :aggregate_failures do
        expect(Controller.safe_domain?(URI("https://example.com/bukalapak.com"))).to be_falsey
        expect(Controller.safe_domain?(URI('https://www.bukalapak.com.evil.com'))).to be_falsey
      end

      it "disallows an allowed domain if we prepend subdomain bits" do
        expect(Controller.safe_domain?(URI("https://evil.documents.foo.com/access/jwt?token=123"))).to be_falsey
      end

      it "disallows an allowed domain if URI scheme is different" do
        expect(Controller.safe_domain?(URI("http://www.bukalapak.com"))).to be_falsey
      end
    end
    
  end
end
