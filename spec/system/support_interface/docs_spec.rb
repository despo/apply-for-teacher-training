require 'rails_helper'

RSpec.feature 'Docs' do
  include DfESignInHelpers

  scenario 'Support user visits process documentation' do
    given_i_am_a_support_user
    when_i_visit_the_process_documentation
    then_i_see_the_provider_flow_documentation
    and_it_contains_documentation_for_all_emails

    when_i_click_on_candidate_flow_documentation
    then_i_see_the_candidate_flow_documentation
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_process_documentation
    visit support_interface_provider_flow_path
  end

  def then_i_see_the_provider_flow_documentation
    within '.govuk-tabs' do
      expect(page).to have_title 'Provider application flow'
    end
  end

  def and_it_contains_documentation_for_all_emails
    emails_outside_of_states = %w[
      candidate_mailer-survey_chaser_email
      candidate_mailer-survey_email
      provider_mailer-account_created
      referee_mailer-reference_cancelled_email
      provider_mailer-fallback_sign_in_email
    ]

    # extract all the emails that we send into a list of strings like "referee_mailer-reference_request_chaser_email"
    emails_sent = [CandidateMailer, ProviderMailer, RefereeMailer].flat_map { |k| k.public_instance_methods(false).map { |m| "#{k.name.underscore}-#{m}" } }
    documented_application_choice_emails = I18n.t('events').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq
    documented_chaser_emails = I18n.t('application_states').flat_map { |_name, attrs| attrs[:emails] }.compact.uniq

    emails_documented = documented_application_choice_emails + documented_chaser_emails + emails_outside_of_states

    expect(emails_documented).to match_array(emails_sent)
  end

  def when_i_click_on_candidate_flow_documentation
    within '.govuk-tabs' do
      click_on 'Candidate application flow'
    end
  end

  def then_i_see_the_candidate_flow_documentation
    expect(page).to have_title 'Candidate application flow'
  end
end
