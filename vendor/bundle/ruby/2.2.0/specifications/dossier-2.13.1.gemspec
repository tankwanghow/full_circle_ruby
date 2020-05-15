# -*- encoding: utf-8 -*-
# stub: dossier 2.13.1 ruby lib

Gem::Specification.new do |s|
  s.name = "dossier"
  s.version = "2.13.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["TMA IT"]
  s.date = "2015-08-24"
  s.description = "Easy SQL based report generation with the ability to accept request parameters and render multiple formats."
  s.email = ["developer@tma1.com"]
  s.homepage = "https://github.com/tma1/dossier"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.5"
  s.summary = "SQL based report generation."

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<arel>, [">= 3.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.2"])
      s.add_runtime_dependency(%q<actionpack>, [">= 3.2"])
      s.add_runtime_dependency(%q<actionmailer>, [">= 3.2"])
      s.add_runtime_dependency(%q<railties>, [">= 3.2"])
      s.add_runtime_dependency(%q<haml>, [">= 3.1"])
      s.add_runtime_dependency(%q<responders>, [">= 1.1"])
      s.add_development_dependency(%q<activerecord>, [">= 3.2"])
      s.add_development_dependency(%q<sqlite3>, [">= 1.3.6"])
      s.add_development_dependency(%q<pry>, [">= 0.10.1"])
      s.add_development_dependency(%q<rspec-rails>, [">= 3.3.3"])
      s.add_development_dependency(%q<generator_spec>, ["~> 0.9.3"])
      s.add_development_dependency(%q<capybara>, ["~> 2.4.4"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.10.0"])
    else
      s.add_dependency(%q<arel>, [">= 3.0"])
      s.add_dependency(%q<activesupport>, [">= 3.2"])
      s.add_dependency(%q<actionpack>, [">= 3.2"])
      s.add_dependency(%q<actionmailer>, [">= 3.2"])
      s.add_dependency(%q<railties>, [">= 3.2"])
      s.add_dependency(%q<haml>, [">= 3.1"])
      s.add_dependency(%q<responders>, [">= 1.1"])
      s.add_dependency(%q<activerecord>, [">= 3.2"])
      s.add_dependency(%q<sqlite3>, [">= 1.3.6"])
      s.add_dependency(%q<pry>, [">= 0.10.1"])
      s.add_dependency(%q<rspec-rails>, [">= 3.3.3"])
      s.add_dependency(%q<generator_spec>, ["~> 0.9.3"])
      s.add_dependency(%q<capybara>, ["~> 2.4.4"])
      s.add_dependency(%q<simplecov>, ["~> 0.10.0"])
    end
  else
    s.add_dependency(%q<arel>, [">= 3.0"])
    s.add_dependency(%q<activesupport>, [">= 3.2"])
    s.add_dependency(%q<actionpack>, [">= 3.2"])
    s.add_dependency(%q<actionmailer>, [">= 3.2"])
    s.add_dependency(%q<railties>, [">= 3.2"])
    s.add_dependency(%q<haml>, [">= 3.1"])
    s.add_dependency(%q<responders>, [">= 1.1"])
    s.add_dependency(%q<activerecord>, [">= 3.2"])
    s.add_dependency(%q<sqlite3>, [">= 1.3.6"])
    s.add_dependency(%q<pry>, [">= 0.10.1"])
    s.add_dependency(%q<rspec-rails>, [">= 3.3.3"])
    s.add_dependency(%q<generator_spec>, ["~> 0.9.3"])
    s.add_dependency(%q<capybara>, ["~> 2.4.4"])
    s.add_dependency(%q<simplecov>, ["~> 0.10.0"])
  end
end
