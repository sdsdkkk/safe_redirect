require 'uri'

module SafeRedirect
  def safe_domain?(uri)
    return true if valid_uri?(uri)
    return false if uri.host.nil?

    SafeRedirect.configuration.domain_whitelists.any? do |domain|
      if domain.include?("*")
        rf = domain.split(/(\*)/).map{ |f| f == "*" ? "\\w*" : Regexp.escape(f) }
        regexp = Regexp.new("\\A#{rf.join}\\z")

        safe = uri.host.match(regexp)

        # if domain starts with *. and contains no other wildcards, include the
        # naked domain too (e.g. foo.org when *.foo.org is the whitelist)
        if domain =~ /\A\*\.[^\*]+\z/
          naked_domain = domain.gsub("*.", "")
          safe || uri.host == naked_domain
        else
          safe
        end
      else
        uri.host == domain
      end
    end
  end

  def safe_path(path)
    case path
    when String
      clean_path(path)
    when Hash
      sanitize_hash(path)
    else
      path
    end
  end

  def redirect_to(path, options={})
    target = options[:safe] ? path : safe_path(path)
    super target, options
  rescue NoMethodError
  end

  private

  def clean_path(path)
    uri = URI.parse(path)
    safe_domain?(uri) ? path : SafeRedirect.configuration.default_path
  rescue URI::InvalidURIError
    SafeRedirect.configuration.default_path
  end

  def sanitize_hash(hash)
    protocol = hash[:protocol] || 'http'
    host = hash[:host]
    uri = URI.parse("#{protocol}://#{host}")
    hash.delete(:host) unless safe_domain?(uri)
    hash
  end

  def valid_uri?(uri)
    return false unless uri.host.nil? && uri.scheme.nil?
    return true if uri.path.nil? || uri.path =~ /^\//
    false
  end

end
