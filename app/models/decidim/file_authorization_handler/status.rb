
# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    # Provides information about the current status of the census data
    # for a given organization
    class Status
      def initialize(organization)
        @organization = organization
      end

      # Returns the date of the last import
      def last_import_at
        @last ||= CensusDatum
                  .inside(@organization)
                  .order(created_at: :desc)
                  .first
        @last ? @last.created_at : nil
      end

      # Returns the number of unique census
      def records
        @records ||= CensusDatum
                      .inside(@organization)
                      .group(*FileAuthorizationHandler.search_fields.keys)
                      .count
                      .size
        @records
      end

      # Returns the number of auhtorizations
      def authorized
        @authorized ||= Authorization
                        .where(organization: @organization,
                               name: ::FileAuthorizationHandler.handler_name)
                        .count
        @authorized
      end
    end
  end
end
