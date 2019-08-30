# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    module AdminLog
      # This class holds the logic to present a `RedirectRule` for the `AdminLog` log.
      class CensusDatumPresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete"
            "decidim.file_authorization_handler.admin_log.#{action}"
          end
        end

        # Private: The params to be sent to the i18n string.
        #
        # Returns a Hash.
        def i18n_params
          {
            user_name: user_presenter.present,
            resource_name: present_resource
          }
        end

        # Private: Presents the resource of the action. If the resource is found
        # in the database, it links to it. Otherwise it only shows the resource name.
        #
        # Returns an HTML-safe String.
        def present_resource
          h.content_tag(:span, I18n.t("decidim.authorization_handlers.file_authorization_handler.name"), class: "logs__log__resource")
        end
      end
    end
  end
end
