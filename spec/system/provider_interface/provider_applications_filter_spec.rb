require 'rails_helper'

RSpec.feature 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'can filter applications by status and provider, and location' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_application_filters_are_active
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_applications
    then_only_rejected_applications_should_be_visible
    and_a_rejected_tag_should_be_visible
    and_the_rejected_tickbox_should_still_be_checked

    when_i_filter_for_applications_that_i_do_not_have
    then_i_should_see_the_no_filter_results_error_message
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_and_offered_applications
    then_only_rejected_and_offered_applications_should_be_visible

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible

    when_i_filter_by_provider
    then_i_only_see_applications_for_a_given_provider
    then_i_expect_the_relevant_provider_tags_to_be_visible

    when_i_click_to_remove_a_tag
    then_i_expect_that_tag_not_to_be_visible
    and_the_remaining_filters_to_still_apply

    when_i_clear_the_filters
    and_i_filter_by_accredited_provider
    then_i_only_see_applications_for_a_given_accredited_provider
    then_i_expect_the_relevant_accredited_provider_tags_to_be_visible

    when_i_click_to_remove_an_accredited_provider_tag
    then_i_expect_all_applications_to_be_visible_again

    when_i_filter_by_provider
    then_expect_that_providers_locations_to_be_visible_as_filter_options
    and_when_i_filter_by_a_location
    then_i_expect_applications_not_associated_to_that_locations_to_not_be_visible
    then_i_expect_applications_with_the_selected_location_to_be_visible
    and_i_expect_the_relevant_location_checkbox_to_be_checked
    and_i_expect_the_correct_heading_for_the_locations_in_the_selected_filters_section

    and_i_expect_the_rekevant_location_tags_to_be_visible

    and_provider_application_filters_are_deactivated

    when_i_visit_the_provider_page
  end

  def and_i_expect_the_correct_heading_for_the_locations_in_the_selected_filters_section
    expect(page).to have_css('.moj-filter__selected h3', text: 'Locations for Hoth Teacher Training')
  end

  def and_i_expect_the_relevant_location_checkbox_to_be_checked
    rejected_checkbox = find(:css, '#locations-for-hoth-teacher-training-ironbarrow-high-school')
    expect(rejected_checkbox.checked?).to be(true)
  end

  def and_i_expect_the_rekevant_location_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Ironbarrow High School')
    expect(page).not_to have_css('.moj-filter-tags', text: ':input_config=>[{:type=>"checkbox", :text=>"Ironbarrow High School",')
  end

  def then_i_expect_applications_not_associated_to_that_locations_to_not_be_visible
    cards = find(:css, '.moj-filter-layout__content')
    expect(cards).not_to have_css('Greg Taft')
    expect(cards).not_to have_css('Luke Smith')
  end

  def and_when_i_filter_by_a_location
    find(:css, '#provider-hoth-teacher-training').set(true)
    find(:css, '#locations-for-hoth-teacher-training-ironbarrow-high-school').set(true)
    click_button('Apply filters')
  end

  def then_i_expect_applications_with_the_selected_location_to_be_visible
    cards = find(:css, '.moj-filter-layout__content')
    expect(cards).to have_content('Jim James')
    expect(cards).to have_content('Adam Jones')
    expect(cards).to have_content('Tom Jones')
    expect(cards).to have_content('Bill Bones')
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_from_multiple_providers
    provider_user_exists_in_apply_database_with_multiple_providers
  end

  def and_my_organisation_has_courses_with_applications
    current_provider_sites = [create(:site, name: 'Ironbarrow High School'), create(:site, name: 'Ostbarrow High')]
    second_provider_sites = [create(:site, name: 'Bishopsheath School'), create(:site, name: 'Thames High')]
    current_provider = create(:provider, :with_signed_agreement, code: 'ABC', name: 'Hoth Teacher Training', sites: current_provider_sites)
    second_provider = create(:provider, :with_signed_agreement, code: 'DEF', name: 'Caladan University', sites: second_provider_sites)
    third_provider = create(:provider, :with_signed_agreement, code: 'GHI', name: 'University of Arrakis')

    accredited_provider1 = create(:provider, code: 'JKL', name: 'College of Dumbervale')
    accredited_provider2 = create(:provider, code: 'MNO', name: 'Wimleydown University')

    course_option_one = course_option_for_provider(provider: current_provider,
                                                   site: current_provider.sites.first,
                                                   course: create(:course,
                                                                  name: 'Alchemy',
                                                                  provider: current_provider,
                                                                  accredited_provider: accredited_provider1))

    course_option_two = course_option_for_provider(provider: current_provider,
                                                   site: current_provider.sites.first,
                                                   course: create(:course,
                                                                  name: 'Divination',
                                                                  provider: current_provider,
                                                                  accredited_provider: accredited_provider2))

    course_option_three = course_option_for_provider(provider: current_provider,
                                                     site: current_provider.sites.first,
                                                     course: create(:course,
                                                                    name: 'English',
                                                                    provider: current_provider))

    course_option_four = course_option_for_provider(provider: second_provider,
                                                    course: create(:course,
                                                                   name: 'Science',
                                                                   provider: second_provider))

    course_option_five = course_option_for_provider(provider: second_provider,
                                                    course: create(:course,
                                                                   name: 'History',
                                                                   provider: second_provider))

    course_option_six = course_option_for_provider(provider: third_provider,
                                                   course: create(:course,
                                                                  name: 'Maths',
                                                                  provider: third_provider))

    course_option_seven = course_option_for_provider(provider: third_provider,
                                                     course: create(:course,
                                                                    name: 'Engineering',
                                                                    provider: third_provider))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_one,
           status: 'withdrawn',
           updated_at: 1.day.ago,
           application_form: create(:application_form,
                                    first_name: 'Jim',
                                    last_name: 'James'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_two,
           status: 'offer',
           updated_at: 2.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Adam',
                                    last_name: 'Jones'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_two,
           status: 'rejected',
           updated_at: 2.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Tom',
                                    last_name: 'Jones'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_three,
           status: 'declined',
           updated_at: 3.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Bill',
                                    last_name: 'Bones'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_four,
           status: 'offer',
           updated_at: 4.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Greg',
                                    last_name: 'Taft'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_five,
           status: 'rejected',
           updated_at: 5.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Paul',
                                    last_name: 'Atreides'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_six,
           status: 'withdrawn',
           updated_at: 6.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Duncan',
                                    last_name: 'Idaho'))

    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option_seven,
           status: 'declined',
           updated_at: 7.days.ago,
           application_form: create(:application_form,
                                    first_name: 'Luke',
                                    last_name: 'Smith'))
  end

  def then_expect_that_providers_locations_to_be_visible_as_filter_options
    filter_dialogue = find(:css, '.moj-filter')
    expect(filter_dialogue).to have_content('Locations for Hoth Teacher Training')
    expect(filter_dialogue).to have_content('Ironbarrow High School')
    expect(filter_dialogue).to have_content('Ostbarrow High')

    expect(filter_dialogue).to have_content('Locations for Caladan University')
    expect(filter_dialogue).to have_content('Bishopsheath School')
    expect(filter_dialogue).to have_content('Thames High')
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_button('Apply filters')
  end

  def when_i_filter_for_rejected_applications
    find(:css, '#status-rejected').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_applications_should_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).not_to have_css('.app-application-cards', text: 'Offer')
    expect(page).not_to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).not_to have_css('.app-application-cards', text: 'Declined')
  end

  def and_the_rejected_tickbox_should_still_be_checked
    rejected_checkbox = find(:css, '#status-rejected')
    expect(rejected_checkbox.checked?).to be(true)
  end

  def when_i_filter_for_applications_that_i_do_not_have
    find(:css, '#status-rejected').set(false)
    find(:css, '#status-accepted').set(true)
    click_button('Apply filters')
  end

  def then_i_should_see_the_no_filter_results_error_message
    expect(page).to have_content('No applications for the selected filters.')
  end

  def when_i_filter_for_rejected_and_offered_applications
    find(:css, '#status-accepted').set(false)
    find(:css, '#status-rejected').set(true)
    find(:css, '#status-offered').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_and_offered_applications_should_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).not_to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).not_to have_css('.app-application-cards', text: 'Declined')
  end

  def when_i_clear_the_filters
    click_link('Clear')
  end

  def then_i_expect_all_applications_to_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).to have_css('.app-application-cards', text: 'Declined')
  end

  def when_i_filter_by_provider
    find(:css, '#provider-hoth-teacher-training').set(true)
    find(:css, '#provider-caladan-university').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_provider
    expect(page).to have_css('.app-application-cards', text: 'Hoth Teacher Training')
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
    expect(page).not_to have_css('.app-application-cards', text: 'University of Arrakis')
  end

  def and_provider_application_filters_are_active
    FeatureFlag.activate('provider_application_filters')
  end

  def and_i_filter_by_accredited_provider
    find(:css, '#accredited_provider-wimleydown-university').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_accredited_provider
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).not_to have_content('Jim James')
  end

  def then_i_expect_the_relevant_accredited_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Wimleydown University')
    expect(page).not_to have_css('.moj-filter-tags', text: 'College of Dumbervale')
  end

  def and_provider_application_filters_are_deactivated
    FeatureFlag.deactivate('provider_application_filters')
  end

  def then_i_expect_the_relevant_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def when_i_click_to_remove_a_tag
    click_link('Hoth Teacher Training')
  end

  def then_i_expect_that_tag_not_to_be_visible
    expect(page).not_to have_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def and_the_remaining_filters_to_still_apply
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
  end

  def and_a_rejected_tag_should_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Rejected')
  end

  def when_i_click_to_remove_an_accredited_provider_tag
    click_link('Wimleydown University')
  end

  def then_i_expect_all_applications_to_be_visible_again
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).to have_content('Jim James')
  end
end
