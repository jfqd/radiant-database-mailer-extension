# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-database_mailer-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-database_mailer-extension"
  s.version     = RadiantDatabaseMailerExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantDatabaseMailerExtension::AUTHORS
  s.email       = RadiantDatabaseMailerExtension::EMAIL
  s.homepage    = RadiantDatabaseMailerExtension::URL
  s.summary     = RadiantDatabaseMailerExtension::SUMMARY
  s.description = RadiantDatabaseMailerExtension::DESCRIPTION

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
  
  # s.add_dependency 'radiant-mailer-extension', '~> 1.1'
  # s.add_dependency "json_fields"
  s.add_dependency "spreadsheet"
end