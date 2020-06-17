require 'rails_helper'

RSpec.feature 'Selecting a course' do
  include CandidateHelper

  scenario 'Candidate selects a course choice' do
    given_the_replace_full_or_withdrawn_application_choices_is_active
    and_i_have_submitted_my_application
    and_one_of_my_application_choices_has_become_full
    and_there_are_course_options

    when_i_arrive_at_my_application_dashboard
    and_i_click_update_my_course_choice
    and_i_choose_to_replace_my_course
    then_i_see_the_have_you_chosen_page

    when_i_choose_that_i_know_where_i_want_to_apply
    then_i_see_the_pick_replacment_provider_page

    when_i_choose_a_provider
    then_i_should_see_a_course_and_its_description

    when_submit_without_choosing_a_course
    then_i_should_see_an_error

    when_i_choose_a_course
    then_i_see_the_pick_replacment_study_mode_page
    then_i_see_the_address
    and_i_choose_a_location
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
    @course_choice = @application.application_choices.first
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def and_there_are_course_options
    @provider = create(:provider)
    @course = create(:course, provider: @provider)
    create(:course, provider: @provider)
    @site = create(:site, provider: @provider)
    @site2 = create(:site, provider: @provider)
    @full_time_course_option = create(:course_option, :full_time, site: @site, course: @course)
    create(:course_option, :part_time, site: @site, course: @course)
    create(:course_option, site: @site2, course: @course)
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_update_my_course_choice
    click_link 'Update your course choice now'
  end

  def and_i_choose_to_replace_my_course
    choose 'Choose a different course'
    click_button 'Continue'
  end

  def then_i_see_the_have_you_chosen_page
    expect(page).to have_current_path candidate_interface_replace_course_choices_choose_path(@course_choice.id)
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def then_i_see_the_pick_replacment_provider_page
    expect(page).to have_current_path candidate_interface_relace_course_choices_provider_path(@course_choice.id)
  end

  def when_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_button 'Continue'
  end

  def then_i_should_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description)
  end

  def when_submit_without_choosing_a_course
    click_button 'Continue'
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'Select a course'
  end

  def when_i_choose_a_course
    choose @course.name
    click_button 'Continue'
  end

  def then_i_see_the_pick_replacment_study_mode_page
    expect(page).to have_current_path candidate_interface_pick_replacement_provider_path
  end

  def then_i_see_the_address
    expect(page).to have_content(@site.name_and_address )
  end

  def and_i_choose_a_location
    choose @site.address_line1
    click_button 'Continue'
  end
end
