class DeclineOffer
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    @application_choice.change_state!(:decline, declined_at: Time.zone.now)
    StateChangeNotifier.call(:offer_declined, application_choice: @application_choice)
  end
end
