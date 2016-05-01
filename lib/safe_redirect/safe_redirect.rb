module SafeRedirect
  def safe_domain?(path)
    whitelists = SafeRedirect.configuration.domain_whitelists || []
    path =~ /^\// && !(path =~ /^\/\/+/)  ||
    whitelists.any? do |w|
      path =~ /^https?:\/\/#{w}($|\/.*)/
    end
  end

  def safe_path(path)
    if path.kind_of?(String)
      stripped_path = path.strip
      if safe_domain?(stripped_path)
        stripped_path
      else
        stripped_path.gsub(/https?:\/\/[a-z0-9\-\.:]*/i, '')
                     .gsub(/^(data:|javascript:|\.|\/\/|@)+/i, '')
      end
    else
      SafeRedirect.configuration.default_path
    end
  end

  def redirect_to(path, options)
    super safe_path(path), options
  end
end