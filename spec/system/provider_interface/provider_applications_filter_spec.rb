require 'rails_helper'

RSpec.feature 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'can filter applications by status' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_hide_filter_button
    then_i_expect_to_see_the_filter_dialogue

    when_i_hide_the_filter_dialogue
    then_i_do_not_expect_to_see_the_filter_dialogue

    when_i_show_the_filter_dialogue
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_applications
    then_only_rejected_applications_should_be_visible
    and_the_rejected_tickbox_should_still_be_checked

    when_i_filter_for_applications_that_i_do_not_have
    then_i_should_see_the_no_filter_results_error_message
    then_i_expect_to_see_the_hide_filter_button
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_and_offered_applications
    when_i_hide_the_filter_dialogue
    then_only_rejected_and_offered_applications_should_be_visible
    when_i_show_the_filter_dialogue
    then_only_rejected_and_offered_applications_should_be_visible

    when_i_sort_by_name
    then_only_rejected_and_offered_applications_should_be_visible

    when_i_hide_the_filter_dialogue
    when_i_sort_by_course
    then_only_rejected_and_offered_applications_should_be_visible
    then_i_do_not_expect_to_see_the_filter_dialogue

    when_i_show_the_filter_dialogue
    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible
    save_and_open_page

    when_i_filter_by_provider
    then_i_only_see_applications_for_a_given_provider

  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_from_multiple_providers
    provider_user_exists_in_apply_with_multiple_providers
  end

  def and_my_organisation_has_courses_with_applications
    current_provider = create(:provider, :with_signed_agreement, code: 'ABC', name: 'Hoth Teacher Training')
    second_provider = create(:provider, :with_signed_agreement, code: 'DEF', name: 'Caladan University')
    third_provider = create(:provider, :with_signed_agreement, code: 'GHI', name: 'University of Arrakis')

    course_option_one = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Alchemy', provider: current_provider))
    course_option_two = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Divination', provider: current_provider))
    course_option_three = course_option_for_provider(provider: current_provider, course: create(:course, name: 'English', provider: current_provider))

    course_option_four = course_option_for_provider(provider: second_provider, course: create(:course, name: 'Science', provider: second_provider))
    course_option_five = course_option_for_provider(provider: second_provider, course: create(:course, name: 'History', provider: second_provider))

    course_option_six = course_option_for_provider(provider: third_provider, course: create(:course, name: 'Maths', provider: third_provider))
    course_option_seven = course_option_for_provider(provider: third_provider, course: create(:course, name: 'Engineering', provider: third_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'rejected', application_form:
           create(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           create(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_four, status: 'offer', application_form:
           create(:application_form, first_name: 'Greg', last_name: 'Taft'), updated_at: 4.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_five, status: 'rejected', application_form:
           create(:application_form, first_name: 'Paul', last_name: 'Atreides'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_six, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Duncan', last_name: 'Idaho'), updated_at: 6.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_seven, status: 'declined', application_form:
           create(:application_form, first_name: 'Luke', last_name: 'Smith'), updated_at: 7.days.ago)
  end

  def then_i_expect_to_see_the_hide_filter_button
    expect(page).to have_content('Hide filter')
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_submit_button('Apply filters')
  end

  def when_i_hide_the_filter_dialogue
    click_link('Hide filter')
  end

  def then_i_do_not_expect_to_see_the_filter_dialogue
    expect(page).not_to have_submit_button('Apply filters')
  end

  def when_i_show_the_filter_dialogue
    click_link('Show filter')
  end

  def when_i_filter_for_rejected_applications
    find(:css, '#status-rejected').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_applications_should_be_visible
    expect(page).to have_css('.govuk-table__body', text: 'Rejected')
    expect(page).not_to have_css('.govuk-table__body', text: 'Offer')
    expect(page).not_to have_css('.govuk-table__body', text: 'Application withdrawn')
    expect(page).not_to have_css('.govuk-table__body', text: 'Declined')
  end

  def and_the_rejected_tickbox_should_still_be_checked
    rejected_checkbox = find(:css, '#status-rejected')
    expect(rejected_checkbox.checked?).to be(true)
  end

  def when_i_filter_for_applications_that_i_do_not_have
    find(:css, '#status-rejected').set(false)
    find(:css, '#status-pending_conditions').set(true)
    click_button('Apply filters')
  end

  def then_i_should_see_the_no_filter_results_error_message
    expect(page).to have_content('No applications for the selected filters.')
  end

  def when_i_filter_for_rejected_and_offered_applications
    find(:css, '#status-pending_conditions').set(false)
    find(:css, '#status-rejected').set(true)
    find(:css, '#status-offer').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_and_offered_applications_should_be_visible
    expect(page).to have_css('.govuk-table__body', text: 'Rejected')
    expect(page).to have_css('.govuk-table__body', text: 'Offer')
    expect(page).not_to have_css('.govuk-table__body', text: 'Application withdrawn')
    expect(page).not_to have_css('.govuk-table__body', text: 'Declined')
  end

  def when_i_sort_by_name
    click_link('Name')
  end

  def when_i_sort_by_course
    click_link('Course')
  end

  def when_i_clear_the_filters
    click_link('Clear')
  end

  def then_i_expect_all_applications_to_be_visible
    expect(page).to have_css('.govuk-table__body', text: 'Rejected')
    expect(page).to have_css('.govuk-table__body', text: 'Offer')
    expect(page).to have_css('.govuk-table__body', text: 'Application withdrawn')
    expect(page).to have_css('.govuk-table__body', text: 'Declined')
  end


  def when_i_filter_by_provider
    find(:css, '#provider-1').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_provider
    expect(page).to have_css('.govuk-table__body', text: 'Hoth Teacher Training')
    expect(page).not_to have_css('.govuk-table__body', text: 'Caladan University')
    expect(page).not_to have_css('.govuk-table__body', text: 'University of Arrakis')
  end
end
