# -*- encoding: utf-8 -*-
# stub: meta_request 0.7.2 ruby lib

Gem::Specification.new do |s|
  s.name = "meta_request".freeze
  s.version = "0.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dejan Simic".freeze]
  s.date = "2019-08-03"
  s.description = "Supporting gem for Rails Panel (Google Chrome extension for Rails development)".freeze
  s.email = "desimic@gmail.com".freeze
  s.homepage = "https://github.com/dejan/rails_panel/tree/master/meta_request".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Request your Rails request".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, ["< 7", ">= 3.0.0"])
      s.add_runtime_dependency(%q<rack-contrib>.freeze, ["< 3", ">= 1.1"])
    else
      s.add_dependency(%q<railties>.freeze, ["< 7", ">= 3.0.0"])
      s.add_dependency(%q<rack-contrib>.freeze, ["< 3", ">= 1.1"])
    end
  else
    s.add_dependency(%q<railties>.freeze, ["< 7", ">= 3.0.0"])
    s.add_dependency(%q<rack-contrib>.freeze, ["< 3", ">= 1.1"])
  end
end
