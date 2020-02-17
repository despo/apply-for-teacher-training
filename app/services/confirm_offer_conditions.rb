class ConfirmOfferConditions
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    @application_choice.change_state!(
      :confirm_conditions_met,
      recruited_at: Time.zone.now
    )
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
