# frozen_string_literal: true

namespace :dynamic do
  task init: ["generate:migration", "install:migration"]

  namespace :generate do
    desc "Generates a customized migration"
    task migration: :environment do
      gem_root = Gem::Specification.find_by_name("decidim-file_authorization_handler").gem_dir
      default_migration_name = "default_create_decidim_file_authorization_handler_census_datum.rb"
      default_migration_path = File.join(gem_root,"config", default_migration_name)
      text = File.read(default_migration_path)
      columns = Decidim::FileAuthorizationHandler.configuration.fields.map do |name, options|
        "t.#{options[:type]} :#{name}"
      end.join("\n      ")
      timestamp = Time.now.to_formatted_s(:number)
      file_name = Rails.root.join("db", "migrate", default_migration_name.gsub("default", timestamp))
      File.write(file_name, text.gsub("#insert columns#", columns))
    end
  end

  namespace :install do
    desc "Install and run migration"
    task :migration do
      system("bundle exec rake db:migrate")
    end
  end
end
