module SafeRedirect
  def safe_domain?(path)
    path =~ /^\// && !(path =~ /^\/\/+/)  ||
    SafeRedirect.configuration.domain_whitelists.any? do |w|
      path =~ /^https?:\/\/#{w}($|\/.*)/
    end
  end

  def safe_path(path)
    if path.kind_of?(String)
      stripped_path = path.strip
      if safe_domain?(stripped_path)
        stripped_path
      else
        stripped_path.gsub!(/https?:\/\/[a-z0-9\-\.:@]*/i, '')
        stripped_path.gsub!(/^(data:|javascript:|\.|\/\/|@)+/i, '')
        stripped_path
      end
    else
      SafeRedirect.configuration.default_path
    end
  end

  def redirect_to(path, options={})
    super safe_path(path), options
  rescue NoMethodError
  end
end