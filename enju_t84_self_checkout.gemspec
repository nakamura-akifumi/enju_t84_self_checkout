$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_t84_self_checkout/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_t84_self_checkout"
  s.version     = EnjuT84SelfCheckout::VERSION
  s.authors     = ["Akifumi NAKAMURA"]
  s.email       = ["tmpz84@gmail.com"]
  s.homepage    = "https://github.com/nakamura-akifumi/enju_t84_self_checkout"
  s.summary     = "Summary of EnjuT84SelfCheckout."
  s.description = "Description of EnjuT84SelfCheckout."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "sqlite3"
end
