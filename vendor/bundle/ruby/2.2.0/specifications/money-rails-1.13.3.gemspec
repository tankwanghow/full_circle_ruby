# -*- encoding: utf-8 -*-
# stub: money-rails 1.13.3 ruby lib

Gem::Specification.new do |s|
  s.name = "money-rails"
  s.version = "1.13.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/RubyMoney/money-rails/issues", "changelog_uri" => "https://github.com/RubyMoney/money-rails/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/RubyMoney/money-rails/" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Andreas Loupasakis", "Shane Emmons", "Simone Carletti"]
  s.date = "2019-10-16"
  s.description = "This library provides integration of RubyMoney - Money gem with Rails"
  s.email = ["alup.rubymoney@gmail.com"]
  s.homepage = "https://github.com/RubyMoney/money-rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.5"
  s.summary = "Money gem integration with Rails"

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<money>, ["~> 6.13.2"])
      s.add_runtime_dependency(%q<monetize>, ["~> 1.9.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0"])
      s.add_runtime_dependency(%q<railties>, [">= 3.0"])
      s.add_development_dependency(%q<rails>, [">= 3.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 3.0"])
      s.add_development_dependency(%q<database_cleaner>, ["~> 1.6.1"])
      s.add_development_dependency(%q<test-unit>, ["~> 3.0"])
    else
      s.add_dependency(%q<money>, ["~> 6.13.2"])
      s.add_dependency(%q<monetize>, ["~> 1.9.0"])
      s.add_dependency(%q<activesupport>, [">= 3.0"])
      s.add_dependency(%q<railties>, [">= 3.0"])
      s.add_dependency(%q<rails>, [">= 3.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 3.0"])
      s.add_dependency(%q<database_cleaner>, ["~> 1.6.1"])
      s.add_dependency(%q<test-unit>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<money>, ["~> 6.13.2"])
    s.add_dependency(%q<monetize>, ["~> 1.9.0"])
    s.add_dependency(%q<activesupport>, [">= 3.0"])
    s.add_dependency(%q<railties>, [">= 3.0"])
    s.add_dependency(%q<rails>, [">= 3.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 3.0"])
    s.add_dependency(%q<database_cleaner>, ["~> 1.6.1"])
    s.add_dependency(%q<test-unit>, ["~> 3.0"])
  end
end
