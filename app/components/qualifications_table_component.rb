class QualificationsTableComponent < ViewComponent::Base
  attr_reader :qualifications, :type_label

  def initialize(qualifications:, type_label:)
    @qualifications = qualifications
    @type_label = type_label
  end
end
