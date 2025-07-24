module WhoisServerCore
  DOMAIN_NAME_REGEXP = /\A[a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{1,61}\.
  ([a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{1,61}\.)?[a-z0-9]{1,61}\z/x.freeze
end
