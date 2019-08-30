# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    module Admin
      class CensusesController < Decidim::Admin::ApplicationController
        def show
          enforce_permission_to :show, :authorization
          @status = Status.new(current_organization)
        end

        def create
          enforce_permission_to :create, :authorization
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
          enforce_permission_to :destroy, :authorization, organization: current_organization
          CensusDatum.clear(current_organization)
          Authorization.where(organization: current_organization, name: "file_authorization_handler").delete_all
          redirect_to censuses_path, notice: t(".success")
        end
      end
    end
  end
end
