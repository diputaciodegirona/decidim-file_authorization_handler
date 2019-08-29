# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class CensusDatum < ApplicationRecord
      # rubocop:disable Rails/InverseOf
      belongs_to :organization, foreign_key: :decidim_organization_id,
        class_name: "Decidim::Organization"
      # rubocop:enable Rails/InverseOf

      # An organzation scope
      def self.inside(organization)
        where(decidim_organization_id: organization.id)
      end

      # Search for a specific document id inside a organization
      def self.search(organization, fields_hash)
        CensusDatum.inside(organization)
        .where(fields_hash.transform_values(&:encode))
        .order(created_at: :desc, id: :desc)
        .first
      end

      # Normalizes a id document string (remove invalid characters) and encode it
      # to conform with Decidim privacy guidelines.
      def self.normalize_and_encode_id_document(id_document)
        return "" unless id_document
        id_document = id_document.gsub(/[^A-z0-9]/, "").upcase
        return "" if id_document.blank?
        Digest::SHA256.hexdigest(
          "#{id_document}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      # temporary
      def self.fields
        @fields ||= FileAuthorizationHandler.fields
      end

      def self.process_row(row)
        raise unless row.transform_keys!(&:to_sym).keys == fields.keys

        row.map do |key, value|
          value = self.validate(key, value) if fields[key][:format]
          value = self.parse(key, value) if fields[key][:parse]
          value = self.encode(key, value) if fields[key][:search]
          value
        end
      end

      def self.validate(key, value)
        value.match(fields[key][:format]) ? value : raise
      end

      # # Convert a date from string to a Date object
      # def self.parse_date(string)
      #   Date.strptime((string || "").strip, "%d/%m/%Y")
      # rescue StandardError
      #   nil
      # end

      # Encodes the value to conform with Decidim privacy guidelines.
      def self.encode(key, value)
        return unless value

        Digest::SHA256.hexdigest(
          "#{value}-#{Rails.application.secrets.secret_key_base}"
        )
      end

      # Convert a date from string to a Date object
      def self.parse(key, value)
        fields[key][:parse].call(value)
      end

      def self.before_insertion
        # Implement this in your model decorator if you would like to perform
        # some processing before insertion happens (optional).
      end

      # Insert a collection of values
      def self.insert_all(organization, values)
        return if values.empty?

        table_name = CensusDatum.table_name
        columns = (fields.keys + %w(decidim_organization_id created_at)).join(",")
        now = Time.current
        byebug
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
