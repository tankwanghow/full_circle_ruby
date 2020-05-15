# -*- encoding: utf-8 -*-
# stub: ffaker 1.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ffaker".freeze
  s.version = "1.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Emmanuel Oga".freeze]
  s.date = "2012-07-03"
  s.description = "Faster Faker, generates dummy data.".freeze
  s.email = "EmmanuelOga@gmail.com".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze, "LICENSE".freeze, "Changelog.rdoc".freeze]
  s.files = ["Changelog.rdoc".freeze, "LICENSE".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/emmanueloga/ffaker".freeze
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubyforge_project = "ffaker".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Faster Faker, generates dummy data.".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
  end
end
