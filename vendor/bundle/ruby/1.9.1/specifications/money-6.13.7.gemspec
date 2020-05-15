# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "money"
  s.version = "6.13.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Emmons", "Anthony Dmitriyev"]
  s.date = "2020-01-05"
  s.description = "A Ruby Library for dealing with money and currency conversion."
  s.email = ["shane@emmons.io", "anthony.dmitriyev@gmail.com"]
  s.homepage = "https://rubymoney.github.io/money"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A Ruby Library for dealing with money and currency conversion."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<i18n>, ["<= 2", ">= 0.6.4"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.4"])
      s.add_development_dependency(%q<yard>, ["~> 0.9.11"])
      s.add_development_dependency(%q<kramdown>, ["~> 1.1"])
    else
      s.add_dependency(%q<i18n>, ["<= 2", ">= 0.6.4"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.4"])
      s.add_dependency(%q<yard>, ["~> 0.9.11"])
      s.add_dependency(%q<kramdown>, ["~> 1.1"])
    end
  else
    s.add_dependency(%q<i18n>, ["<= 2", ">= 0.6.4"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.4"])
    s.add_dependency(%q<yard>, ["~> 0.9.11"])
    s.add_dependency(%q<kramdown>, ["~> 1.1"])
  end
end
