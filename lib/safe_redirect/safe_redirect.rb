require 'uri'

module SafeRedirect
  def safe_domain?(uri)
    return true if uri.host.nil? && uri.scheme.nil?
    SafeRedirect.configuration.domain_whitelists.include?(uri.host)
  end

  def safe_path(path)
    case path
    when String
      clean_path(path)
    when Symbol, Hash
      path
    else
      SafeRedirect.configuration.default_path
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
    safe_domain?(uri) ? path : '/'
  rescue URI::InvalidURIError
    '/'
  end
end
