# This worker will be scheduled to run nightly
class SendApplicationToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.application_complete?

    ActiveRecord::Base.transaction do
      application_choice.change_state!(:send_to_provider, reject_by_default_dates)
      StateChangeNotifier.call(:send_application_to_provider, application_choice: application_choice)
      SendNewApplicationEmailToProvider.new(application_choice: application_choice).call
    end
  end

private

  def reject_by_default_dates
    time_limit = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: Time.zone.now,
    ).call

    days = time_limit[:days]
    time = time_limit[:time_in_future]

    {
      reject_by_default_days: days,
      reject_by_default_at: time,
    }
  end
end
