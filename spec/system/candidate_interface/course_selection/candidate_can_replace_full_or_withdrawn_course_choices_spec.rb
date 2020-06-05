require 'rails_helper'

RSpec.describe 'A course option selected by a candidate has become full or been withdrawn' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'when a candidate arrives at the dashboard they can follow the replace course flow' do
    given_the_replace_full_or_withdrawn_application_choices_is_active
    and_i_have_submitted_my_application
    and_one_of_my_application_choices_has_become_full
    and_another_course_exists

    when_i_arrive_at_my_application_dashboard
    then_i_see_that_one_of_my_choices_in_not_available

    when_i_click_update_my_application_choice
    then_i_arrive_on_the_update_application_choice_page

    when_i_choose_to_add_a_different_course
    and_i_select_a_new_course
    then_i_see_the_confirmation_page
    and_i_see_my_full_application_choice
    and_i_see_my_replacement_application_choice

    when_i_click_replace_application_choice
    then_i_see_the_update_application_page

    when_i_click_update_application
    then_i_arrive_at_my_application_dashboard
    and_i_am_told_my_application_has_been_updated
    and_i_see_my_replacement_application_choice
    and_i_cannot_see_my_replaced_application_choice
  end

  def given_the_replace_full_or_withdrawn_application_choices_is_active
    FeatureFlag.activate('replace_full_or_withdrawn_application_choices')
  end

  def and_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_one_of_my_application_choices_has_become_full
    @course_option = @application.application_choices.first.course_option
    @course_option.no_vacancies!
  end

  def and_another_course_exists
    course_option_for_provider_code(provider_code: '1N1')
    @course_option2 = CourseOption.last
  end

  def when_i_arrive_at_my_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_see_that_one_of_my_choices_in_not_available
    expect(page).to have_content 'One of your choices is not available anymore.'
  end

  def when_i_click_update_my_application_choice
    click_link 'Update your course choice now.'
  end

  def then_i_arrive_on_the_update_application_choice_page
    expect(page).to have_curent_path candidate_interface_replace_application_choice_path(@course_option.id)
  end

  def when_i_choose_to_add_a_different_course
    choose 'Choose a different course'
  end

  def and_i_select_a_new_course
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    choose @course_option2.course.name_and_code
    click_button 'Continue'
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_curent_path candidate_interface_replace_application_choice_path(@course_option1.id, @course_option2.id)
  end

  def and_i_see_my_full_application_choice
    expect(page).to have content @course_option.course.name
  end

  def and_i_see_my_replacement_application_choice
    expect(page).to have content @course_option2.course.name
  end

  def when_i_click_replace_application_choice
    click_button 'Replace course choice'
  end

  def then_i_see_the_update_application_page
    expect(page).to have_curent_path candidate_interface_confirm_application_choice_update_path(@course_option1.id, @course_option2.id)
  end

  def when_i_click_update_application
    click_button 'Update application'
  end

  def then_i_arrive_at_my_application_dashboard
    expect(page).to have_current_path candidate_interface_application_complete_path
  end

  def and_i_am_told_my_application_has_been_updated
    expect(page).to have_content 'Your application has been updated'
  end

  def and_i_cannot_see_my_replaced_application_choice
    expect(page).not_to have content @course_option.course.name
  end
end
