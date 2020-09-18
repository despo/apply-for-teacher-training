require 'rails_helper'

RSpec.feature 'Manually carry over unsubmitted applications' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'Carry over application and remove all application choices when new cycle opens' do
    given_i_am_signed_in_as_a_candidate
    and_i_am_in_the_2020_recruitment_cycle
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_start_now
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_return_to_application
    then_i_can_see_that_i_need_to_select_courses_when_apply_reopens
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_am_in_the_2020_recruitment_cycle
    allow(RecruitmentCycle).to receive(:current_year).and_return(2020)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @unrequested_references = create_list(
      :reference,
      2,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
  end

  def and_the_recruitment_cycle_ends
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0))
  ensure
    Timecop.safe_mode = true
  end

  def and_the_cancel_unsubmitted_applications_worker_runs
    CancelUnsubmittedApplicationsWorker.new.perform
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_am_redirected_to_the_carry_over_interstitial
    expect(page).not_to have_link 'Get your application ready to submit from 13 October 2020'
  end

  def when_i_click_on_start_now
    click_button 'Start now'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    click_on 'Referees'
  end

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_content('First referee')
    expect(page).to have_content('Second referee')
    @unrequested_references.each do |reference|
      expect(page).to have_content(reference.name)
    end
  end

  def when_i_return_to_application
    click_link 'Back to application'
  end

  def then_i_can_see_that_i_need_to_select_courses_when_apply_reopens
    expect(page).to have_content 'You can apply for courses from 13 October.'
    expect(page).not_to have_link 'Course choices'
  end
end