# frozen_string_literal: true

require "csv"

module Decidim
  module FileAuthorizationHandler
    class CsvData
      attr_reader :errors, :values

      def initialize(file)
        @col_sep = FileAuthorizationHandler.configuration.col_sep
        @file = file
        @errors = []
        @values = []

        Rails.logger.info "[#{self.class}] col_sep: '#{@col_sep}'"
        CSV.foreach(@file, headers: true, col_sep: @col_sep) do |row|
          process_row(row)
        end
      end

      private

      def process_row(row)
        values << CensusDatum.process_row(row.to_h)
      rescue StandardError => e
        Rails.logger.info "[#{self.class}] Error: #{e.message}"
        errors << row
      end
    end
  end
end
