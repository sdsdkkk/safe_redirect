require 'uri'
require 'pry'

module SafeRedirect
  def safe_domain?(uri)
    return true if valid_uri?(uri)
    return false if uri.host.nil?

    safe = false
    SafeRedirect.configuration.domain_whitelists.any? do |domain|
      domain_uri = URI(domain)

      # check scheme match
      next if !domain_uri.scheme.nil? && uri.scheme != domain_uri.scheme

      # check host match
      if domain.include?("*")
        rf = domain_uri.host.split(/(\*)/).map { |f| f == "*" ? "[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9]?" : Regexp.escape(f) }
        regexp = Regexp.new("\\A#{rf.join}\\z")

        safe = !uri.host.match(regexp).nil?

        # if domain starts with *. and contains no other wildcards, include the
        # naked domain too (e.g. foo.org when *.foo.org is the whitelist)
        if domain_uri.host =~ /\A\*\.[^\*]+\z/
          naked_domain_host = domain_uri.host.gsub("*.", "")
          domain_uri.host = uri.host if safe

          safe ||= uri_component_match?(uri_component: uri.host, required_component: naked_domain_host) || uri_component_match?(uri_component: uri.host, required_component: domain_uri.host)
        end
      else
        safe = uri_component_match?(uri_component: uri.host, required_component: domain_uri.host)
      end

      # check path match
      safe &= uri_component_match?(uri_component: uri.path, required_component: domain_uri.path)
    end
    safe
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

    log("Unsafe redirect path modified to #{target} from #{path}", :warn) if target != path

    super target, options
  rescue NoMethodError
  end

  private

  def clean_path(path)
    uri = URI.parse(path)
    valid_path?(path) && safe_domain?(uri) ? path : SafeRedirect.configuration.default_path
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
    return true if uri.host && whitelist_local? && local_address?(uri.host)
    return false unless uri.host.nil? && uri.scheme.nil?
    return true if uri.path.nil? || uri.path =~ /^\//
    false
  end

  def valid_path?(path)
    path !~ /\/\/\//
  end

  def whitelist_local?
    SafeRedirect.configuration.whitelist_local
  end

  # borrowed the regex from https://github.com/rack/rack/blob/ea9e7a570b7ffd8ac6845a9ebecdd7de0af6b0ca/lib/rack/request.rb#L420
  def local_address?(host)
    host =~ /\A127\.0\.0\.1\Z|\A(10|172\.(1[6-9]|2[0-9]|30|31)|192\.168)\.|\A::1\Z|\Afd[0-9a-f]{2}:.+|\Alocalhost\Z|\Aunix\Z|\Aunix:/i
  end

  def log(msg, level = :warn)
    return unless (logger = SafeRedirect.configuration.log)

    msg = "[#{Time.now}] SafeRedirect: #{msg}"

    if logger.respond_to?(level)
      logger.send(level, msg)
    elsif defined?(Rails)
      Rails.logger.send(level, msg)
    end
  end

  def uri_component_match?(uri_component:, required_component:)
    if !required_component.nil?
      # extract the parts in this element and ignore trailing "/"
      # check if all parts in required_component match exactly with the first parts of uri
      # eg. required_component: /bill matches uri: /bill/token=123 but not /not-bill/token=123
      required_parts = required_component.split("/")
      return false if required_parts != uri_component&.split("/")&.first(required_parts.size)
    end
    true
  end
end
