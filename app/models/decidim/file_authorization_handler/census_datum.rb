# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class CensusDatum < ApplicationRecord
      # rubocop:disable Rails/InverseOf
      belongs_to :organization, foreign_key: :decidim_organization_id,
        class_name: "Decidim::Organization"
      # rubocop:enable Rails/InverseOf

      # Sets the presenter class for the :admin_log for a RedirectRule resource.
      def self.log_presenter_class_for(_log)
        Decidim::FileAuthorizationHandler::AdminLog::CensusDatumPresenter
      end

      # An organzation scope
      def self.inside(organization)
        where(decidim_organization_id: organization.id)
      end

      # Search for a specific document id inside a organization
      def self.search(organization, search_fields)
        CensusDatum.inside(organization)
        .where(search_fields.transform_values{|v|encode(v)})
        .order(created_at: :desc, id: :desc)
        .first
      end

      # temporary
      def self.fields
        @fields ||= FileAuthorizationHandler.fields
      end

      def self.process_row(row)
        raise("headers") unless row.transform_keys!(&:to_sym).keys == fields.keys

        row.map do |key, value|
          value = validate(value, fields[key][:format])
          value = parse(value, fields[key][:parse])
          value = encode(value) if fields[key][:search]
          value
        end
      end

      def self.validate(value, regexp)
        return value unless regexp

        value.match(regexp) ? value : raise("format => #{value}")
      end

      # Convert a date from string to a Date object
      def self.parse(value, procedure)
        return value unless procedure

        procedure.call(value)
      rescue StandardError
        raise("parse => #{value}")
      end

      # Encodes the value to conform with Decidim privacy guidelines.
      def self.encode(value)
        Digest::SHA256.hexdigest(
          "#{value}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      # Insert a collection of values
      def self.insert_all(organization, values)
        return if values.empty?

        table_name = CensusDatum.table_name
        columns = (fields.keys + %w(decidim_organization_id created_at)).join(",")
        now = Time.current
        values = values.map { |row| "(#{row.map{|r| "'#{r}'"}.join(', ')}, '#{organization.id}', '#{now}')" }
        sql = "INSERT INTO #{table_name} (#{columns}) VALUES #{values.join(",")}"
        ActiveRecord::Base.connection.execute(sql)
      end

      # Clear all census data for a given organization
      def self.clear(organization)
        CensusDatum.inside(organization).delete_all
      end
    end
  end
end
