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
  s.summary     = "enjut84selfcheckout plugin."
  s.description = "Self checkout module for Next-L Enju."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/{log,private,solr,tmp}/**/*"] - Dir["spec/dummy/db/*.sqlite3"]

  s.add_dependency "rails", "~> 4.2.10"
  s.add_dependency 'pg', '~> 0.15'
  s.add_dependency 'enju_circulation', '~> 0.2.5'
  s.add_dependency "statesman", "~> 3.4"
  s.add_dependency 'faraday'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'faraday-cookie_jar'

  s.add_development_dependency "enju_leaf", "~> 1.2.2"
  s.add_development_dependency "enju_biblio", "~> 0.2.5"
  s.add_development_dependency "enju_manifestation_viewer", "~> 0.2.4"
  s.add_development_dependency "enju_ndl", "~> 0.2.3"
  s.add_development_dependency "enju_event", "~> 0.2.3"
  s.add_development_dependency "enju_circulation", "~> 0.2.5"
  #s.add_development_dependency "sqlite3"
  #s.add_development_dependency "mysql2", "~> 0.4.10"
  s.add_development_dependency "pg", "~> 0.21"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "sunspot_solr", "2.2.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "kramdown"
  s.add_development_dependency "sunspot-rails-tester"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "coveralls"
  s.add_development_dependency 'faraday'
  s.add_development_dependency 'faraday_middleware'
  s.add_development_dependency 'faraday-cookie_jar'

end
