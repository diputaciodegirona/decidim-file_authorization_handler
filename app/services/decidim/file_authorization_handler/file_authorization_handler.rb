# rubocop:disable Style/FrozenStringLiteralComment

module Decidim
  module FileAuthorizationHandler
    # An AuthorizationHandler that uses information uploaded from a CSV file
    # to authorize against.
    class FileAuthorizationHandler < Decidim::AuthorizationHandler
      FileAuthorizationHandler.fields.each do |name, options|
        attribute name, options[:type].to_s.classify.constantize
        validates_presence_of name
        if options[:format]
          validates_format_of name, with: options[:format],  message: I18n.t("errors.messages.#{name}_format")
        end
      end

      validate :user_must_be_found_in_census

      private

      def search_fields_keys
        FileAuthorizationHandler.fields.select { |_k,v| v[:search]}.keys
      end

      def search_fields
        attributes[*search_fields_keys]
      end

      def unique_id
        Digest::SHA256.hexdigest(
          "#{search_fields_keys.join("-")}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      # Checks if the id_document belongs to the census
      def user_must_be_found_in_census
        return if errors.any? || census_for_user

        search_fields_keys.each do |field|
          errors.add(field, I18n.t("decidim.file_authorization_handler.errors.messages.not_found"))
        end
      end

      def census_for_user
        @census_for_user ||= CensusDatum.search(search_fields)
      end
    end
  end
end
