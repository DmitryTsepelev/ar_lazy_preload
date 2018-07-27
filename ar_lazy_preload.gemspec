$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "ar_lazy_preload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ar_lazy_preload"
  s.version     = ArLazyPreload::VERSION
  s.authors     = ["DmitryTsepelev"]
  s.email       = ["dmitry.a.tsepelev@gmail.com"]
  s.homepage    = "https://github.com/DmitryTsepelev/ar_lazy_preload"
  s.summary     = "lazy_preload implementation for ActiveRecord models"
  s.description = "lazy_preload implementation for ActiveRecord models"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "db-query-matchers"
end
