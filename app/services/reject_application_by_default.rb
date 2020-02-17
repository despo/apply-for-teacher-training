class RejectApplicationByDefault
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    ActiveRecord::Base.transaction do
      application_choice.change_state!(
        :reject_by_default,
        rejected_by_default: true,
        rejected_at: Time.zone.now,
      )

      SetDeclineByDefault.new(application_form: application_choice.application_form).call
      StateChangeNotifier.call(:reject_application_by_default, application_choice: application_choice)
      SendRejectByDefaultEmailToProvider.new(application_choice: application_choice).call
    end
  end
end
