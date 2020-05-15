# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ffaker"
  s.version = "1.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Emmanuel Oga"]
  s.date = "2012-07-03"
  s.description = "Faster Faker, generates dummy data."
  s.email = "EmmanuelOga@gmail.com"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", "Changelog.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Changelog.rdoc"]
  s.homepage = "http://github.com/emmanueloga/ffaker"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "ffaker"
  s.rubygems_version = "1.8.23"
  s.summary = "Faster Faker, generates dummy data."

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
  end
end
