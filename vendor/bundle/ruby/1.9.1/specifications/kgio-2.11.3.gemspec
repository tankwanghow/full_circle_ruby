# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "kgio"
  s.version = "2.11.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["kgio hackers"]
  s.date = "2020-01-08"
  s.description = "This is a legacy project, do not use it for new projects.  Ruby\n2.3 and later should make this obsolete.  kgio provides\nnon-blocking I/O methods for Ruby without raising exceptions on\nEAGAIN and EINPROGRESS.\n"
  s.email = "kgio-public@yhbt.net"
  s.extensions = ["ext/kgio/extconf.rb"]
  s.extra_rdoc_files = ["LICENSE", "README", "TODO", "NEWS", "LATEST", "ISSUES", "HACKING", "ext/kgio/accept.c", "ext/kgio/autopush.c", "ext/kgio/connect.c", "ext/kgio/kgio_ext.c", "ext/kgio/poll.c", "ext/kgio/wait.c", "ext/kgio/tryopen.c"]
  s.files = ["LICENSE", "README", "TODO", "NEWS", "LATEST", "ISSUES", "HACKING", "ext/kgio/accept.c", "ext/kgio/autopush.c", "ext/kgio/connect.c", "ext/kgio/kgio_ext.c", "ext/kgio/poll.c", "ext/kgio/wait.c", "ext/kgio/tryopen.c", "ext/kgio/extconf.rb"]
  s.homepage = "https://yhbt.net/kgio/"
  s.licenses = ["LGPL-2.1+"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "kinder, gentler I/O for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, ["~> 3.0"])
    else
      s.add_dependency(%q<test-unit>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<test-unit>, ["~> 3.0"])
  end
end
