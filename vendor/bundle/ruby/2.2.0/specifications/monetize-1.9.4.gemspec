# -*- encoding: utf-8 -*-
# stub: monetize 1.9.4 ruby lib

Gem::Specification.new do |s|
  s.name = "monetize"
  s.version = "1.9.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/RubyMoney/monetize/issues", "changelog_uri" => "https://github.com/RubyMoney/monetize/blob/master/CHANGELOG.md", "source_code_uri" => "https://github.com/RubyMoney/monetize/" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Shane Emmons", "Anthony Dmitriyev"]
  s.date = "2020-01-07"
  s.description = "A library for converting various objects into `Money` objects."
  s.email = ["shane@emmons.io", "anthony.dmitriyev@gmail.com"]
  s.homepage = "https://github.com/RubyMoney/monetize"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.5"
  s.summary = "A library for converting various objects into `Money` objects."

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<money>, ["~> 6.12"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 10.2"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
    else
      s.add_dependency(%q<money>, ["~> 6.12"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 10.2"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<money>, ["~> 6.12"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 10.2"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
  end
end
