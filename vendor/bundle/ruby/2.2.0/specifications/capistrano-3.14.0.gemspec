# -*- encoding: utf-8 -*-
# stub: capistrano 3.14.0 ruby lib

Gem::Specification.new do |s|
  s.name = "capistrano"
  s.version = "3.14.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/capistrano/capistrano/issues", "changelog_uri" => "https://github.com/capistrano/capistrano/releases", "documentation_uri" => "https://capistranorb.com/", "homepage_uri" => "https://capistranorb.com/", "source_code_uri" => "https://github.com/capistrano/capistrano" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Tom Clements", "Lee Hambley"]
  s.date = "2020-05-06"
  s.description = "Capistrano is a utility and framework for executing commands in parallel on multiple remote machines, via SSH."
  s.email = ["seenmyfate@gmail.com", "lee.hambley@gmail.com"]
  s.executables = ["cap", "capify"]
  s.files = ["bin/cap", "bin/capify"]
  s.homepage = "https://capistranorb.com/"
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0")
  s.rubygems_version = "2.4.5.5"
  s.summary = "Capistrano - Welcome to easy deployment with Ruby over SSH"

  s.installed_by_version = "2.4.5.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<airbrussh>, [">= 1.0.0"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 10.0.0"])
      s.add_runtime_dependency(%q<sshkit>, [">= 1.9.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rubocop>, ["= 0.48.1"])
    else
      s.add_dependency(%q<airbrussh>, [">= 1.0.0"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 10.0.0"])
      s.add_dependency(%q<sshkit>, [">= 1.9.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rubocop>, ["= 0.48.1"])
    end
  else
    s.add_dependency(%q<airbrussh>, [">= 1.0.0"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 10.0.0"])
    s.add_dependency(%q<sshkit>, [">= 1.9.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rubocop>, ["= 0.48.1"])
  end
end
