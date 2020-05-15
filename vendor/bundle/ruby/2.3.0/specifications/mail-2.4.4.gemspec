# -*- encoding: utf-8 -*-
# stub: mail 2.4.4 ruby lib

Gem::Specification.new do |s|
  s.name = "mail".freeze
  s.version = "2.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mikel Lindsaar".freeze]
  s.date = "2012-03-14"
  s.description = "A really Ruby Mail handler.".freeze
  s.email = "raasdnil@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze, "CONTRIBUTING.md".freeze, "CHANGELOG.rdoc".freeze, "TODO.rdoc".freeze]
  s.files = ["CHANGELOG.rdoc".freeze, "CONTRIBUTING.md".freeze, "README.md".freeze, "TODO.rdoc".freeze]
  s.homepage = "http://github.com/mikel/mail".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Mail provides a nice Ruby DSL for making, sending and reading emails.".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>.freeze, ["~> 1.16"])
      s.add_runtime_dependency(%q<treetop>.freeze, ["~> 1.4.8"])
      s.add_runtime_dependency(%q<i18n>.freeze, [">= 0.4.0"])
    else
      s.add_dependency(%q<mime-types>.freeze, ["~> 1.16"])
      s.add_dependency(%q<treetop>.freeze, ["~> 1.4.8"])
      s.add_dependency(%q<i18n>.freeze, [">= 0.4.0"])
    end
  else
    s.add_dependency(%q<mime-types>.freeze, ["~> 1.16"])
    s.add_dependency(%q<treetop>.freeze, ["~> 1.4.8"])
    s.add_dependency(%q<i18n>.freeze, [">= 0.4.0"])
  end
end
