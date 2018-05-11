# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    # Defines the abilities related to surveys for a logged in admin user.
    # Intended to be used with `cancancan`.
    class Permissions < Decidim::DefaultPermissions
      def permissions
        puts "ouieaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        return permission_action unless user
        return Decidim::FileAuthorizationHandler::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
      end
    end
  end
end
