# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::FileAuthorizationHandler::Status, type: :model do
  let(:organization) { FactoryBot.create :organization }

  it "returns last import date" do
    last = FactoryBot.create :census_datum, organization: organization
    status = Decidim::FileAuthorizationHandler::Status.new(organization)
    expect(last.created_at.to_i).to eq status.last_import_at.to_i
  end

  it "retrieve the number of unique documents" do
    %w(AAA BBB AAA AAA).each do |doc|
      FactoryBot.create(:census_datum, id_document: doc, organization: organization)
    end
    status = Decidim::FileAuthorizationHandler::Status.new(organization)
    expect(status.count).to be 2
  end
end
