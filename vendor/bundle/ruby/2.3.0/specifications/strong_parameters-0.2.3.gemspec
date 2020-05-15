# -*- encoding: utf-8 -*-
# stub: strong_parameters 0.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "strong_parameters".freeze
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2014-01-20"
  s.email = ["david@heinemeierhansson.com".freeze]
  s.homepage = "https://github.com/rails/strong_parameters".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Permitted and required parameters for Action Pack".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<activemodel>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<railties>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["~> 3.0"])
      s.add_dependency(%q<actionpack>.freeze, ["~> 3.0"])
      s.add_dependency(%q<activemodel>.freeze, ["~> 3.0"])
      s.add_dependency(%q<railties>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["~> 3.0"])
    s.add_dependency(%q<actionpack>.freeze, ["~> 3.0"])
    s.add_dependency(%q<activemodel>.freeze, ["~> 3.0"])
    s.add_dependency(%q<railties>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
