# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    module Admin
      class CensusesController < Decidim::Admin::ApplicationController
        def show
          authorize! :show, CensusDatum
          @status = Status.new(current_organization)
        end

        def create
          authorize! :create, CensusDatum
          if params[:file]
            data = CsvData.new(params[:file].path)
            CensusDatum.insert_all(current_organization, data.values)
            RemoveDuplicatesJob.perform_later(current_organization)
            flash[:notice] = t(".success", count: data.values.count,
                                           errors: data.errors.count)
          end
          redirect_to censuses_path
        end

        def destroy
          authorize! :create, CensusDatum
          CensusDatum.clear(current_organization)
          redirect_to censuses_path, notice: t(".success")
        end
      end
    end
  end
end
