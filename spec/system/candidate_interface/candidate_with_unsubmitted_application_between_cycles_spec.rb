require 'rails_helper'

RSpec.feature 'Candidate attempts to submit the application after the end-of-cycle cutoff' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 24)) { example.run }
  end

  scenario 'Candidate with an unsubmitted application between cycles' do
    given_i_am_signed_in

    when_i_have_completed_my_application
    and_i_return_after_submission_deadline
    and_i_visit_the_application_form_page

    then_i_can_only_review_my_application
    and_i_cannot_submit_my_application

    when_i_try_to_visit_the_submit_page
    then_i_am_redirected_to_the_application_page

    when_i_return_after_new_cycle_opens
    and_i_log_in_again
    and_i_visit_the_application_form_page
    then_i_can_see_the_submit_link
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_return_after_submission_deadline
    Timecop.travel(Time.zone.local(2020, 8, 25, 12, 0, 0))
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def then_i_can_only_review_my_application
    expect(page).not_to have_link 'Check and submit your application'
    expect(page).to have_content 'Applications for courses starting in 2021 open from 13 October'
    click_link 'Review your application'
  end

  def and_i_cannot_submit_my_application
    expect(page).not_to have_link 'Continue'
  end

  def when_i_try_to_visit_the_submit_page
    visit candidate_interface_application_submit_show_path
  end

  def then_i_am_redirected_to_the_application_page
    expect(page).to have_content('Applications for courses starting this academic year have now closed')
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def when_i_return_after_new_cycle_opens
    Timecop.travel(Time.zone.local(2020, 10, 13, 12, 0, 0))
  end

  def and_i_log_in_again
    logout
    create_and_sign_in_candidate
  end

  def then_i_can_see_the_submit_link
    expect(page).to have_link 'Check and submit your application'
  end
end