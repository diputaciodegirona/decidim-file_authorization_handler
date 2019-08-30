# frozen_string_literal: true

require "decidim/file_authorization_handler/admin"
require "decidim/file_authorization_handler/engine"
require "decidim/file_authorization_handler/admin_engine"
require "decidim/file_authorization_handler/configuration"

module Decidim
  # Base module for this engine.
  module FileAuthorizationHandler
    class << self
      attr_accessor :configuration

      def fields
        configuration.fields
      end

      def search_fields
        fields.select { |_k,v| v[:search]}
      end

      def configure
        @configuration ||= Configuration.new
        yield(configuration)
      end
    end
  end
end
