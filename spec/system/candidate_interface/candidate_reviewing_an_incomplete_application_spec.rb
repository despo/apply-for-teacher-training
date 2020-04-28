require 'rails_helper'

RSpec.feature 'Candidate reviewing an incomplete application' do
  include CandidateHelper

  scenario 'sees everything missing from the current state' do
    given_i_am_signed_in
    and_the_suitability_to_work_with_children_feature_flag_is_on

    when_i_visit_the_review_application_page
    then_i_should_be_able_to_click_through_and_complete_each_section_but_science_gcse

    when_i_confirm_my_application
    then_i_should_see_an_error_that_i_have_not_completed_everything
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_suitability_to_work_with_children_feature_flag_is_on
    FeatureFlag.activate('suitability_to_work_with_children')
  end

  def when_i_visit_the_review_application_page
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
  end

  def then_i_should_be_able_to_click_through_and_complete_each_section_but_science_gcse
    (CandidateHelper::APPLICATION_FORM_SECTIONS - [:science_gcse]).each do |section|
      expect(page).to have_selector "[aria-describedby='missing-#{section}']"
      within "#missing-#{section}-error" do
        expect(page).to have_link('Complete section')
      end
    end
  end

  def when_i_confirm_my_application
    click_link 'Continue'
  end

  def then_i_should_see_an_error_that_i_have_not_completed_everything
    expect(page).to have_content t('page_titles.review_application')
    expect(page).to have_content 'There is a problem'
  end
end
