# -*- encoding: utf-8 -*-
# stub: sentient_user 0.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "sentient_user".freeze
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["bokmann".freeze]
  s.date = "2011-01-17"
  s.description = "lets the User model in most authentication frameworks know who is the current user\"".freeze
  s.email = "dbock@codesherpas.com".freeze
  s.extra_rdoc_files = ["LICENSE".freeze, "README.rdoc".freeze]
  s.files = ["LICENSE".freeze, "README.rdoc".freeze]
  s.homepage = "http://github.com/bokmann/sentient_user".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "A trivial bit of common code".freeze

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>.freeze, [">= 2.11.3"])
    else
      s.add_dependency(%q<shoulda>.freeze, [">= 2.11.3"])
    end
  else
    s.add_dependency(%q<shoulda>.freeze, [">= 2.11.3"])
  end
end
