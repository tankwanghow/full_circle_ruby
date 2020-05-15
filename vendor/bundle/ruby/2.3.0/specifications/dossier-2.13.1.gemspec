# -*- encoding: utf-8 -*-
# stub: dossier 2.13.1 ruby lib

Gem::Specification.new do |s|
  s.name = "dossier".freeze
  s.version = "2.13.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["TMA IT".freeze]
  s.date = "2015-08-24"
  s.description = "Easy SQL based report generation with the ability to accept request parameters and render multiple formats.".freeze
  s.email = ["developer@tma1.com".freeze]
  s.homepage = "https://github.com/tma1/dossier".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2".freeze
  s.summary = "SQL based report generation.".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<arel>.freeze, [">= 3.0"])
      s.add_runtime_dependency(%q<activesupport>.freeze, [">= 3.2"])
      s.add_runtime_dependency(%q<actionpack>.freeze, [">= 3.2"])
      s.add_runtime_dependency(%q<actionmailer>.freeze, [">= 3.2"])
      s.add_runtime_dependency(%q<railties>.freeze, [">= 3.2"])
      s.add_runtime_dependency(%q<haml>.freeze, [">= 3.1"])
      s.add_runtime_dependency(%q<responders>.freeze, [">= 1.1"])
      s.add_development_dependency(%q<activerecord>.freeze, [">= 3.2"])
      s.add_development_dependency(%q<sqlite3>.freeze, [">= 1.3.6"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0.10.1"])
      s.add_development_dependency(%q<rspec-rails>.freeze, [">= 3.3.3"])
      s.add_development_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
      s.add_development_dependency(%q<capybara>.freeze, ["~> 2.4.4"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
    else
      s.add_dependency(%q<arel>.freeze, [">= 3.0"])
      s.add_dependency(%q<activesupport>.freeze, [">= 3.2"])
      s.add_dependency(%q<actionpack>.freeze, [">= 3.2"])
      s.add_dependency(%q<actionmailer>.freeze, [">= 3.2"])
      s.add_dependency(%q<railties>.freeze, [">= 3.2"])
      s.add_dependency(%q<haml>.freeze, [">= 3.1"])
      s.add_dependency(%q<responders>.freeze, [">= 1.1"])
      s.add_dependency(%q<activerecord>.freeze, [">= 3.2"])
      s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.6"])
      s.add_dependency(%q<pry>.freeze, [">= 0.10.1"])
      s.add_dependency(%q<rspec-rails>.freeze, [">= 3.3.3"])
      s.add_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
      s.add_dependency(%q<capybara>.freeze, ["~> 2.4.4"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
    end
  else
    s.add_dependency(%q<arel>.freeze, [">= 3.0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.2"])
    s.add_dependency(%q<actionpack>.freeze, [">= 3.2"])
    s.add_dependency(%q<actionmailer>.freeze, [">= 3.2"])
    s.add_dependency(%q<railties>.freeze, [">= 3.2"])
    s.add_dependency(%q<haml>.freeze, [">= 3.1"])
    s.add_dependency(%q<responders>.freeze, [">= 1.1"])
    s.add_dependency(%q<activerecord>.freeze, [">= 3.2"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.6"])
    s.add_dependency(%q<pry>.freeze, [">= 0.10.1"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 3.3.3"])
    s.add_dependency(%q<generator_spec>.freeze, ["~> 0.9.3"])
    s.add_dependency(%q<capybara>.freeze, ["~> 2.4.4"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.10.0"])
  end
end
