require 'rails_helper'

RSpec.feature 'Candidate submits the application' do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    given_i_am_signed_in
    and_the_covid_19_feature_flag_is_on

    when_i_have_completed_my_application

    and_i_review_my_application

    then_i_should_see_all_sections_are_complete
    and_i_can_see_my_course_choices
    and_i_can_see_my_personal_details
    and_i_can_see_my_contact_details
    and_i_can_see_my_disability_disclosure
    and_i_can_see_my_safeguarding_issues
    and_i_can_see_my_volunteering_roles
    and_i_can_see_my_degree
    and_i_can_see_my_gcses
    and_i_can_see_my_other_qualification
    and_i_can_see_my_becoming_a_teacher_info
    and_i_can_see_my_subject_knowlegde_info
    and_i_can_see_my_interview_preferences
    and_i_can_see_my_referees

    and_i_confirm_my_application

    when_i_choose_to_add_further_information_but_omit_adding_details
    then_i_should_see_validation_errors

    when_i_fill_in_further_information
    and_i_can_submit_the_application

    then_i_can_see_my_application_has_been_successfully_submitted

    and_i_can_see_my_support_ref
    and_that_covid_19_may_affect_my_application
    and_i_receive_an_email_with_my_support_ref
    and_my_referees_receive_a_request_for_a_reference_by_email
    and_a_slack_notification_is_sent

    when_i_click_on_track_your_application
    then_i_can_see_my_application_dashboard
    and_i_see_the_covid_19_guidance

    when_i_click_view_application
    then_i_can_see_my_submitted_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_covid_19_feature_flag_is_on
    FeatureFlag.activate('covid_19')
  end

  def and_the_suitability_to_work_with_children_feature_flag_is_on
    FeatureFlag.activate('suitability_to_work_with_children')
  end

  def and_the_covid_19_feature_flag_is_on
    FeatureFlag.activate('covid_19')
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def and_i_review_my_application
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_all_sections_are_complete
    CandidateHelper::APPLICATION_FORM_SECTIONS.each do |section|
      expect(page).not_to have_selector "[aria-describedby='missing-#{section}']"
    end
  end

  def and_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
  end

  def and_i_can_see_my_personal_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
    expect(page).to have_content "I'm great at Galactic Basic so English is a piece of cake"
  end

  def and_i_can_see_my_contact_details
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content '42 Much Wow Street'
    expect(page).to have_content 'London'
    expect(page).to have_content 'SW1P 3BT'
  end

  def and_i_can_see_my_disability_disclosure
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have difficulty climbing stairs'
  end

  def and_i_can_see_my_safeguarding_issues
    expect(page).to have_content 'Yes'
    expect(page).to have_content 'I have a criminal conviction.'
  end

  def and_i_can_see_my_volunteering_roles
    expect(page).to have_content 'Classroom Volunteer'
    expect(page).to have_content 'A Noice School'
    expect(page).to have_content 'I volunteered.'
  end

  def and_i_can_see_my_degree
    expect(page).to have_content 'BA Doge'
    expect(page).to have_content 'University of Much Wow'
    expect(page).to have_content 'First'
    expect(page).to have_content '2009'
  end

  def and_i_can_see_my_gcses
    expect(page).to have_content '1990'
  end

  def and_i_can_see_my_other_qualification
    expect(page).to have_content 'A level Believing in the Heart of the Cards'
    expect(page).to have_content 'Yugi College'
    expect(page).to have_content 'A'
    expect(page).to have_content '2015'
  end

  def and_i_can_see_my_becoming_a_teacher_info
    expect(page).to have_content 'I believe I would be a first-rate teacher'
  end

  def and_i_can_see_my_subject_knowlegde_info
    expect(page).to have_content 'Everything'
  end

  def and_i_can_see_my_interview_preferences
    expect(page).to have_content 'Not on a Wednesday'
  end

  def and_i_can_see_my_referees
    expect(page).to have_content 'Terri Tudor'
    expect(page).to have_content 'terri@example.com'
    expect(page).to have_content 'Tutor'

    expect(page).to have_content 'Anne Other'
    expect(page).to have_content 'anne@other.com'
    expect(page).to have_content 'First boss'
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def when_i_choose_to_add_further_information_but_omit_adding_details
    choose 'Yes'
  end

  def then_i_should_see_validation_errors
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/further_information_form.attributes.further_information_details.blank')
  end

  def when_i_fill_in_further_information
    scope = 'application_form.further_information'
    fill_in t('further_information_details.label', scope: scope), with: "How you doin', ya old pirate? So good to see ya!", match: :prefer_exact
  end

  def and_i_can_submit_the_application
    click_button 'Submit application'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application successfully submitted'
  end

  def and_i_can_see_my_support_ref
    support_ref = page.find('span#application-ref').text
    expect(support_ref).not_to be_empty
  end

  def and_that_covid_19_may_affect_my_application
    expect(page).to have_content 'Coronavirus (COVID-19)'
  end

  def and_i_receive_an_email_with_my_support_ref
    open_email(current_candidate.email_address)
    expect(current_email).to have_content 'Application submitted'
  end

  def and_my_referees_receive_a_request_for_a_reference_by_email
    current_application = current_candidate.current_application
    current_application.application_references.each do |reference|
      open_email(reference.email_address)
      expect(current_email).to have_content "#{current_application.first_name} #{current_application.last_name} put us in touch with you to get a reference"
      expect(current_email).to have_content reference.name
    end
  end

  def and_a_slack_notification_is_sent
    expect_slack_message_with_text 'Lando has just submitted their application'
  end

  def when_i_click_on_track_your_application
    click_link 'To edit your application, return to your application dashboard.', match: :first
  end

  def then_i_can_see_my_application_dashboard
    this_day = Time.zone.now.to_s(:govuk_date)
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content "Application submitted on #{this_day}"
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content current_candidate.current_application.application_references.first.name
    expect(page).to have_content 'Submitted'
  end

  def and_i_see_the_covid_19_guidance
    expect(page).to have_content 'Coronavirus (COVID-19)'
  end

  def when_i_click_view_application
    click_link 'View application'
  end

  def then_i_can_see_my_submitted_application
    expect(page).to have_content t('page_titles.submitted_application')
    expect(page).to have_content Time.zone.now.to_s(:govuk_date)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '07700 900 982'
    expect(page).to have_content 'Classroom Volunteer'
    expect(page).to have_content 'BA Doge'
    expect(page).to have_content 'A level Believing in the Heart of the Cards'
    expect(page).to have_content 'I believe I would be a first-rate teacher'
    expect(page).to have_content 'Everything'
    expect(page).to have_content 'Not on a Wednesday'
    expect(page).to have_content 'Terri Tudor'
  end
end
