# -*- encoding: utf-8 -*-
# stub: pg 1.2.3 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "pg"
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "https://github.com/ged/ruby-pg" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger", "Lars Kanis"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIID+DCCAmCgAwIBAgIBAjANBgkqhkiG9w0BAQsFADAiMSAwHgYDVQQDDBdnZWQv\nREM9RmFlcmllTVVEL0RDPW9yZzAeFw0xOTEyMjQyMDE5NTFaFw0yMDEyMjMyMDE5\nNTFaMCIxIDAeBgNVBAMMF2dlZC9EQz1GYWVyaWVNVUQvREM9b3JnMIIBojANBgkq\nhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAvyVhkRzvlEs0fe7145BYLfN6njX9ih5H\nL60U0p0euIurpv84op9CNKF9tx+1WKwyQvQP7qFGuZxkSUuWcP/sFhDXL1lWUuIl\nM4uHbGCRmOshDrF4dgnBeOvkHr1fIhPlJm5FO+Vew8tSQmlDsosxLUx+VB7DrVFO\n5PU2AEbf04GGSrmqADGWXeaslaoRdb1fu/0M5qfPTRn5V39sWD9umuDAF9qqil/x\nSl6phTvgBrG8GExHbNZpLARd3xrBYLEFsX7RvBn2UPfgsrtvpdXjsHGfpT3IPN+B\nvQ66lts4alKC69TE5cuKasWBm+16A4aEe3XdZBRNmtOu/g81gvwA7fkJHKllJuaI\ndXzdHqq+zbGZVSQ7pRYHYomD0IiDe1DbIouFnPWmagaBnGHwXkDT2bKKP+s2v21m\nozilJg4aar2okb/RA6VS87o+d7g6LpDDMMQjH4G9OPnJENLdhu8KnPw/ivSVvQw7\nN2I4L/ZOIe2DIVuYH7aLHfjZDQv/mNgpAgMBAAGjOTA3MAkGA1UdEwQCMAAwCwYD\nVR0PBAQDAgSwMB0GA1UdDgQWBBRyjf55EbrHagiRLqt5YAd3yb8k4DANBgkqhkiG\n9w0BAQsFAAOCAYEAifxlz7x0EfT3fjhM520ZEIrWa+tLMuLKNefkY18u8tZnx4EX\nXxwh3tna3fvNfrOrdY5leIj1dbv4FTRg+gIBnIxAySqvpGvI/Axg5EdYbwninCLL\nLAKCmRo+5QwaPMYN2zdHIjGrp8jg1neCo5zy6tVvyTv0DMI6FLrydVJYduMMDFSy\ngQKR1rVOcCJtnBnLCF9+kKEUKohAHOmGsE7OBZFnjMIpH5yUDUVJKByv0gIipFt0\n1T6zff6oVU0w8WBiNKR381+6sF3wIZVnVY0XeJg6hNL+YecE8ILxLhHTmtT/BO0S\n3xPze9uXDR+iD6HYl8KU5QEg/dXFPhfQb512vVkTJDZvMcwu6PxDUjHFChLjAji/\nAZXjg1C5E9znTkeUR8ieU9F1MOKoiH57a5lYSTI8Ga8PpsNXTxNeXc16Ob26CqrJ\n83uuAYSy65yXDGXXPVBeKPVnYrqp91pqpS5Nh7wfuiCrE8lgU8PATh7K4BV1UhAT\n0MHbAT42wTYkfUj3\n-----END CERTIFICATE-----\n"]
  s.date = "2020-03-18"
  s.description = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/].\n\nIt works with {PostgreSQL 9.2 and later}[http://www.postgresql.org/support/versioning/].\n\nA small example usage:\n\n  #!/usr/bin/env ruby\n\n  require 'pg'\n\n  # Output a table of current connections to the DB\n  conn = PG.connect( dbname: 'sales' )\n  conn.exec( \"SELECT * FROM pg_stat_activity\" ) do |result|\n    puts \"     PID | User             | Query\"\n    result.each do |row|\n      puts \" %7d | %-16s | %s \" %\n        row.values_at('procpid', 'usename', 'current_query')\n    end\n  end"
  s.email = ["ged@FaerieMUD.org", "lars@greiz-reinsdorf.de"]
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["Contributors.rdoc", "History.rdoc", "Manifest.txt", "README-OS_X.rdoc", "README-Windows.rdoc", "README.ja.rdoc", "README.rdoc", "ext/errorcodes.txt", "POSTGRES", "LICENSE", "ext/gvl_wrappers.c", "ext/pg.c", "ext/pg_binary_decoder.c", "ext/pg_binary_encoder.c", "ext/pg_coder.c", "ext/pg_connection.c", "ext/pg_copy_coder.c", "ext/pg_errors.c", "ext/pg_record_coder.c", "ext/pg_result.c", "ext/pg_text_decoder.c", "ext/pg_text_encoder.c", "ext/pg_tuple.c", "ext/pg_type_map.c", "ext/pg_type_map_all_strings.c", "ext/pg_type_map_by_class.c", "ext/pg_type_map_by_column.c", "ext/pg_type_map_by_mri_type.c", "ext/pg_type_map_by_oid.c", "ext/pg_type_map_in_ruby.c", "ext/pg_util.c"]
  s.files = ["Contributors.rdoc", "History.rdoc", "LICENSE", "Manifest.txt", "POSTGRES", "README-OS_X.rdoc", "README-Windows.rdoc", "README.ja.rdoc", "README.rdoc", "ext/errorcodes.txt", "ext/extconf.rb", "ext/gvl_wrappers.c", "ext/pg.c", "ext/pg_binary_decoder.c", "ext/pg_binary_encoder.c", "ext/pg_coder.c", "ext/pg_connection.c", "ext/pg_copy_coder.c", "ext/pg_errors.c", "ext/pg_record_coder.c", "ext/pg_result.c", "ext/pg_text_decoder.c", "ext/pg_text_encoder.c", "ext/pg_tuple.c", "ext/pg_type_map.c", "ext/pg_type_map_all_strings.c", "ext/pg_type_map_by_class.c", "ext/pg_type_map_by_column.c", "ext/pg_type_map_by_mri_type.c", "ext/pg_type_map_by_oid.c", "ext/pg_type_map_in_ruby.c", "ext/pg_util.c"]
  s.homepage = "https://github.com/ged/ruby-pg"
  s.licenses = ["BSD-2-Clause"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2")
  s.rubygems_version = "2.4.5.5"
  s.summary = "Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/]"

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.10"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<rake-compiler>, ["~> 1.0"])
      s.add_development_dependency(%q<rake-compiler-dock>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.5"])
      s.add_development_dependency(%q<rdoc>, ["~> 5.1"])
      s.add_development_dependency(%q<hoe>, ["~> 3.20"])
    else
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.10"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<rake-compiler>, ["~> 1.0"])
      s.add_dependency(%q<rake-compiler-dock>, ["~> 1.0"])
      s.add_dependency(%q<hoe-bundler>, ["~> 1.0"])
      s.add_dependency(%q<rspec>, ["~> 3.5"])
      s.add_dependency(%q<rdoc>, ["~> 5.1"])
      s.add_dependency(%q<hoe>, ["~> 3.20"])
    end
  else
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.10"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<rake-compiler>, ["~> 1.0"])
    s.add_dependency(%q<rake-compiler-dock>, ["~> 1.0"])
    s.add_dependency(%q<hoe-bundler>, ["~> 1.0"])
    s.add_dependency(%q<rspec>, ["~> 3.5"])
    s.add_dependency(%q<rdoc>, ["~> 5.1"])
    s.add_dependency(%q<hoe>, ["~> 3.20"])
  end
end
