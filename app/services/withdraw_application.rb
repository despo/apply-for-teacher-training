class WithdrawApplication
  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save!
    ActiveRecord::Base.transaction do
      application_choice.change_state!(:withdraw, withdrawn_at: Time.zone.now)

      SetDeclineByDefault.new(application_form: application_choice.application_form).call

      StateChangeNotifier.call(:withdraw, application_choice: application_choice)
    end
  end

private

  attr_reader :application_choice
end
