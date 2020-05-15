# -*- encoding: utf-8 -*-
# stub: pg_search 0.5.7 ruby lib

Gem::Specification.new do |s|
  s.name = "pg_search".freeze
  s.version = "0.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Case Commons, LLC".freeze]
  s.date = "2012-10-07"
  s.description = "PgSearch builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search".freeze
  s.email = ["casecommons-dev@googlegroups.com".freeze]
  s.homepage = "https://github.com/Casecommons/pg_search".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "PgSearch builds ActiveRecord named scopes that take advantage of PostgreSQL's full text search".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>.freeze, [">= 3"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3"])
    else
      s.add_dependency(%q<activerecord>.freeze, [">= 3"])
      s.add_dependency(%q<activesupport>.freeze, [">= 3"])
    end
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 3"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3"])
  end
end
