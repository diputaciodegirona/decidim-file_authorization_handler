# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::FileAuthorizationHandler::Admin
      paths["db/migrate"] = nil

      routes do
        resource :censuses, only: [:show, :create, :destroy]
      end

      initializer "decidim_file_authorization.add_admin_authorizations" do |_app|
        Decidim.configure do |config|
          config.admin_abilities += [
            "Decidim::FileAuthorizationHandler::Abilities::AdminAbility"
          ]
        end
      end

      initializer "decidim_file_authorization.add_admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("decidim.file_authorization_handler.admin.menu.census"),
                    decidim_file_authorization_handler_admin.censuses_path,
                    icon_name: "spreadsheet",
                    position: 7,
                    active: :inclusive
        end
      end

      initializer "decidim_file_authorization.admin_assets" do |app|
        app.config.assets.precompile += %w(decidim/admin/component_permissions.js)
      end
    end
  end
end
