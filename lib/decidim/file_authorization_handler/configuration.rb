# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class Configuration
      attr_accessor :col_sep, :fields

      # {
      #   id_document: {
      #     type: :string,
      #     search: true,
      #     format: /\A[A-Z0-9]*\z/
      #   },
      #   birthdate: {
      #     type: :date,
      #     search: false,
      #     format: %r{\d{2}\/\d{2}\/\d{4}},
      #     parse: proc { |string| Date.strptime(string, "%d/%m/%Y") }
      #   }
      # }
      def initialize
        @col_sep = ","
        @fields = nil
      end
    end
  end
end
