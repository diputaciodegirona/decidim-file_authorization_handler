# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "decidim/file_authorization_handler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "decidim-file_authorization_handler"
  s.version = Decidim::FileAuthorizationHandler::VERSION
  s.authors = ["Daniel Gómez", "Xavier Redó", "Oliver Valls"]
  s.email = ["info@coditramuntana.com"]
  s.summary = "CSV verifier"
  s.description = "Census uploads via csv files"
  s.homepage = "https://github.com/coditramuntana/"
  s.license = "AGPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "decidim", ">= #{Decidim::FileAuthorizationHandler::VERSION}"
  s.add_dependency "decidim-admin", ">= #{Decidim::FileAuthorizationHandler::VERSION}"
  s.add_dependency "rails", ">= 5.2"

  s.add_development_dependency "decidim-dev", ">= #{Decidim::FileAuthorizationHandler::VERSION}"
  s.add_development_dependency "faker"
  s.add_development_dependency 'listen'
  s.add_development_dependency "letter_opener_web", "~> 1.3.3"
end
