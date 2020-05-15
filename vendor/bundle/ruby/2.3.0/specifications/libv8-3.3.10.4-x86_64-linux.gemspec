# -*- encoding: utf-8 -*-
# stub: libv8 3.3.10.4 x86_64-linux lib

Gem::Specification.new do |s|
  s.name = "libv8".freeze
  s.version = "3.3.10.4"
  s.platform = "x86_64-linux".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Logan Lowell".freeze, "Charles Lowell".freeze]
  s.date = "2011-11-15"
  s.description = "Distributes the V8 JavaScript engine in binary and source forms in order to support fast builds of The Ruby Racer".freeze
  s.email = ["fractaloop@thefrontside.net".freeze, "cowboyd@thefrontside.net".freeze]
  s.homepage = "http://github.com/fractaloop/libv8".freeze
  s.rubyforge_project = "libv8".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Distribution of the V8 JavaScript engine".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 0.9.2"])
      s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
      s.add_dependency(%q<bundler>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 0.9.2"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
  end
end
