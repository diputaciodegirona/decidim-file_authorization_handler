# frozen_string_literal: true

# An AuthorizationHandler that uses information uploaded from a CSV file
# to authorize against the age of the user
class FileAuthorizationHandler < Decidim::AuthorizationHandler
  # This is the input (from the user) to validate against
  attribute :id_document, String
  attribute :birthdate, Decidim::Attributes::LocalizedDate

  # This is the validation to perform
  # If passed, an authorization is created
  validates :id_document, presence: true
  validates :birthdate, presence: true
  validate :censed

  def metadata
    @metadata ||= begin
      meta = { birthdate: census_for_user&.birthdate&.strftime("%Y/%m/%d") }
      census_for_user&.extras&.each_pair do |key, value|
        meta[key.to_sym] = value
      end
      meta
    end
  end

  # This is required in new 0.8.4 version of decicim
  # however, there's a bug and this doesn't work
  def handler_name
    +"file_authorization_handler"
  end

  # Checks if the id_document belongs to the census
  def censed
    return if census_for_user&.birthdate == birthdate

    errors.add(:id_document, I18n.t("decidim.file_authorization_handler.errors.messages.not_censed"))
  end

  def authorized?
    return true if census_for_user
  end

  def unique_id
    return nil unless organization
    Digest::SHA256.hexdigest("#{census_for_user&.id_document}-#{organization.id}-#{Rails.application.secrets.secret_key_base}")
  end

  def census_for_user
    return unless organization

    @census_for_user ||= Decidim::FileAuthorizationHandler::CensusDatum
                         .search_id_document(organization, id_document)
  end

  def organization
    current_organization || user&.organization
  end
end
