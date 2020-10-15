require 'rails_helper'

RSpec.feature 'Candidate adding referees in Sandbox', sandbox: true do
  include CandidateHelper

  before { FeatureFlag.deactivate(:decoupled_references) }

  def candidate_provides_two_referees
    visit candidate_interface_referees_type_path
    choose 'Academic'
    click_button 'Continue'

    candidate_fills_in_referee(
      name: 'Refbot One',
      email_address: 'refbot1@example.com',
      relationship: 'First boss',
    )
    click_button 'Save and continue'
    click_link 'Add another referee'

    choose 'Professional'
    click_button 'Continue'

    candidate_fills_in_referee(
      name: 'Refbot Two',
      email_address: 'refbot2@example.com',
      relationship: 'Second boss',
    )
    click_button 'Save and continue'
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  scenario 'Candidate adds two auto-references' do
    given_i_am_signed_in

    when_i_have_completed_my_application
    and_i_review_my_application

    then_i_should_see_all_sections_are_complete

    and_i_confirm_my_application

    when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
    and_i_choose_not_to_add_further_information
    and_i_submit_the_application

    then_i_see_that_the_application_was_sent_to_provider
    and_i_see_that_references_are_given
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def then_i_should_see_all_sections_are_complete
    CandidateHelper::APPLICATION_FORM_SECTIONS.each do |section|
      expect(page).not_to have_selector "[data-qa='missing-#{section}']"
    end
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def when_i_choose_not_to_fill_in_the_equality_and_diversity_survey
    click_link 'Continue without completing questionnaire'
  end

  def and_i_choose_not_to_add_further_information
    choose 'No'
  end

  def and_i_submit_the_application
    click_button(FeatureFlag.active?(:decoupled_references) ? 'Send application' : 'Submit application')
  end

  def then_i_see_that_the_application_was_sent_to_provider
    visit candidate_interface_application_complete_path
    expect(page).to have_content('Status Awaiting decision')
  end

  def and_i_see_that_references_are_given
    expect(page).to have_content('Reference given')
  end
end