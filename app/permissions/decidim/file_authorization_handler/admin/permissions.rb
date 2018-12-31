# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    module Admin
      # Defines the abilities related to surveys for a logged in admin user.
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          if user.organization.available_authorizations.include?("file_authorization_handler")
            if permission_action_in?(:show, :create, :destroy)
              allow! if permission_action.subject == Decidim::FileAuthorizationHandler::CensusDatum
            end
          end
          permission_action
        end

        private

        def permission_action_in?(*actions)
          actions.any? { |action| permission_action.action == action }
        end
      end
    end
  end
end
