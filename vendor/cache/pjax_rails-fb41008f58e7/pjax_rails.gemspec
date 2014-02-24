# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "pjax_rails"
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Heinemeier Hansson (PJAX by Chris Wanstrath)"]
  s.date = "2014-02-24"
  s.email = "david@loudthinking.com"
  s.files = ["lib/pjax_rails.rb", "lib/pjax.rb", "lib/assets/javascripts/pjax/enable_pjax.js", "lib/assets/javascripts/pjax/page_triggers.js", "lib/assets/javascripts/pjax.js", "vendor/assets/javascripts/jquery.pjax.js"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "PJAX integration for Rails 3.1+"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
    else
      s.add_dependency(%q<jquery-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<jquery-rails>, [">= 0"])
  end
end
