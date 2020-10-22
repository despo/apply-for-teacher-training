class UCASMatch < ApplicationRecord
  audited

  belongs_to :candidate

  enum matching_state: {
    initial_emails_sent: 'initial_emails_sent',
    reminder_emails_sent: 'reminder_emails_sent',
    ucas_withdrawal_requested: 'ucas_withdrawal_requested',
    matching_data_updated: 'matching_data_updated',
    new_match: 'new_match',
    processed: 'processed',
  }

  ACTION_NEEDED_STATUSES = %w[initial_emails_sent reminder_emails_sent ucas_withdrawal_requested].freeze

  def action_needed?
    return false if processed?

    dual_application_or_dual_acceptance?
  end

  def dual_application_or_dual_acceptance?
    application_for_the_same_course_in_progress_on_both_services? || application_accepted_on_ucas_and_in_progress_on_apply? || application_accepted_on_apply_and_in_progress_on_ucas?
  end

private

  def ucas_matched_applications
    matching_data.map do |data|
      UCASMatchedApplication.new(data, recruitment_cycle_year)
    end
  end

  def application_for_the_same_course_in_progress_on_both_services?
    application_for_the_same_course_on_both_services = ucas_matched_applications.select(&:both_scheme?)
    application_for_the_same_course_on_both_services.map(&:application_in_progress_on_ucas?).any? && application_for_the_same_course_on_both_services.map(&:application_in_progress_on_apply?).any?
  end

  def application_accepted_on_ucas_and_in_progress_on_apply?
    ucas_matched_applications.map(&:application_accepted_on_ucas?).any? && ucas_matched_applications.map(&:application_in_progress_on_apply?).any?
  end

  def application_accepted_on_apply_and_in_progress_on_ucas?
    ucas_matched_applications.map(&:application_accepted_on_apply?).any? && ucas_matched_applications.map(&:application_in_progress_on_ucas?).any?
  end

  def waiting_for_action_after_initial_email?; end
end
