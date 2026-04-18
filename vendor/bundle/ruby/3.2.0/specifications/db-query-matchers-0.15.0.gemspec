# -*- encoding: utf-8 -*-
# stub: db-query-matchers 0.15.0 ruby lib

Gem::Specification.new do |s|
  s.name = "db-query-matchers".freeze
  s.version = "0.15.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/sds/db-query-matchers/blob/main/CHANGELOG.md" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brigade Engineering".freeze, "Henric Trotzig".freeze, "Joe Lencioni".freeze]
  s.date = "2025-11-03"
  s.email = ["eng@brigade.com".freeze, "henric.trotzig@brigade.com".freeze, "joe.lencioni@brigade.com".freeze]
  s.homepage = "https://github.com/brigade/db-query-matchers".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "RSpec matchers for database queries".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0"])
  s.add_runtime_dependency(%q<rspec>.freeze, [">= 3.0"])
  s.add_development_dependency(%q<activerecord>.freeze, [">= 4.0"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.0"])
end
