# -*- encoding: utf-8 -*-
# stub: sentient_user 0.3.3 ruby lib

Gem::Specification.new do |s|
  s.name = "sentient_user"
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["bokmann"]
  s.date = "2013-12-27"
  s.description = "lets the User model in most authentication frameworks know who is the current user"
  s.email = ["dbock@codesherpas.com"]
  s.homepage = "http://github.com/bokmann/sentient_user"
  s.rubygems_version = "2.4.5.5"
  s.summary = "A trivial bit of common code"

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["= 4.7.5"])
      s.add_development_dependency(%q<minitest_should>, [">= 0"])
      s.add_development_dependency(%q<turn>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
    else
      s.add_dependency(%q<railties>, [">= 3.1"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<minitest>, ["= 4.7.5"])
      s.add_dependency(%q<minitest_should>, [">= 0"])
      s.add_dependency(%q<turn>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<minitest>, ["= 4.7.5"])
    s.add_dependency(%q<minitest_should>, [">= 0"])
    s.add_dependency(%q<turn>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
  end
end
