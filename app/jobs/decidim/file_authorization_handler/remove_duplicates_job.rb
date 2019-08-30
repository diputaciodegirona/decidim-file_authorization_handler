
# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class RemoveDuplicatesJob < ApplicationJob
      queue_as :default

      # temporary
      def search_keys
        FileAuthorizationHandler.search_fields.keys
      end

      def perform(organization)
        duplicated_census(organization).pluck(*search_keys).each do |values|
          CensusDatum.inside(organization)
                     .where(search_keys.zip(values.to_a).to_h)
                     .order(id: :desc)
                     .all[1..-1]
                     .each(&:delete)
        end
      end

      private

      def duplicated_census(organization)
        CensusDatum.inside(organization)
                   .select(*search_keys)
                   .group(*search_keys)
                   .having("count(*)>1")
      end
    end
  end
end
