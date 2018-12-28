# frozen_string_literal: true

FactoryBot.define do
  factory :census_datum, class: Decidim::FileAuthorizationHandler::CensusDatum do
    id_document { "123456789A" }
    birthdate { 20.years.ago }
    organization
  end
end
