# rubocop:disable Style/FrozenStringLiteralComment

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
    { birthdate: census_for_user&.birthdate&.strftime("%Y/%m/%d") }
  end

  # This is required in new 0.8.4 version of decicim
  # however, there's a bug and this doesn't work
  def handler_name
    "file_authorization_handler"
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
    census_for_user&.id_document
  end

  def census_for_user
    @census_for_user ||= Decidim::FileAuthorizationHandler::CensusDatum
                         .search_id_document(organization, id_document)
  end

  def organization
    current_organization || user&.organization
  end
end
