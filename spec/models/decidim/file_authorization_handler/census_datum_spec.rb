# frozen_string_literal: true

require "spec_helper"
RSpec.describe Decidim::FileAuthorizationHandler::CensusDatum, type: :model do
  let(:organization) { FactoryBot.create :organization }

  CensusDatum = Decidim::FileAuthorizationHandler::CensusDatum

  describe "get census for a given identity document" do
    it "returns the last inserted when duplicates" do
      FactoryBot.create(:census_datum, id_document: encode_id_document("AAA"))
      last = FactoryBot.create(:census_datum, id_document: encode_id_document("AAA"), organization: organization)
      expect(CensusDatum.search_id_document(organization, "AAA")).to eq(last)
    end

    it "normalizes the document" do
      census = FactoryBot.create(:census_datum, id_document: encode_id_document("AAA"), organization: organization)
      expect(CensusDatum.search_id_document(organization, "a-a-a")).to eq(census)
    end
  end

  context "insert_all" do
    it "inserts a collection of values" do
      CensusDatum.insert_all(organization, [["1111A", "1990/12/1"], ["2222B", "1990/12/2"]])
      expect(CensusDatum.count).to be 2
      CensusDatum.insert_all(organization, [["1111A", "2001/12/1"], ["3333C", "1990/12/3"]])
      expect(CensusDatum.count).to be 4
    end

    context "when values is empty" do
      it "returns without crashing" do
        CensusDatum.insert_all(organization, [])
      end
    end
  end

  describe "normalization methods" do
    it "normalizes and encodes the id document" do
      expect(CensusDatum.normalize_and_encode_id_document("1234a"))
        .to eq encode_id_document("1234A")
      expect(CensusDatum.normalize_and_encode_id_document("   1234a  "))
        .to eq encode_id_document("1234A")
      expect(CensusDatum.normalize_and_encode_id_document(")($·$")).to eq ""
      expect(CensusDatum.normalize_and_encode_id_document(nil)).to eq ""
    end

    it "normalizes dates" do
      expect(CensusDatum.parse_date("20/3/1992")).to eq Date.strptime("1992/03/20", "%Y/%m/%d")
      expect(CensusDatum.parse_date("1/20/1992")).to be nil
      expect(CensusDatum.parse_date("n/3/1992")).to be nil
    end
  end
end
