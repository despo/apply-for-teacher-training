class DeclineOfferByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    application_choice.change_state!(
      :decline_by_default,
      declined_by_default: true,
      declined_at: Time.zone.now,
    )
  end
end
