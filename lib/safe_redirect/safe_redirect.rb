module SafeRedirect
  def safe_domain?(path)
    path =~ /^\// && !(path =~ /^\/\/+/)  ||
    SafeRedirect.configuration.domain_whitelists.any? do |w|
      path =~ /^https?:\/\/#{w}($|\/.*)/i
    end
  end

  def safe_path(path)
    case
    when path.kind_of?(String)
      clean_path(path)
    when path.kind_of?(Symbol) || path.kind_of?(Hash)
      path
    else
      SafeRedirect.configuration.default_path
    end
  end

  def redirect_to(path, options={})
    target = options[:safe] ? path : safe_path(path)
    super safe_path(target), options
  rescue NoMethodError
  end

  private

  def clean_path(path)
    stripped_path = path.strip
    unless safe_domain?(stripped_path)
      stripped_path.gsub!(/https?:\/\/[a-z0-9\-\.:@]*/i, '')
      stripped_path.gsub!(/^(data:|javascript:|\.|\/\/|@)+[a-z0-9\-\.:@]*/i, '')
    end
    stripped_path.empty? ? '/' : stripped_path
  end
end
