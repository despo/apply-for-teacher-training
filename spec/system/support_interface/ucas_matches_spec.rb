require 'rails_helper'

RSpec.feature 'See UCAS matches' do
  include DfESignInHelpers

  scenario 'Support agent visits UCAS matches pages' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_there_are_ucas_matches_in_the_system
    and_i_visit_the_support_page

    when_i_go_to_ucas_matches_page
    then_i_should_see_list_of_ucas_matches
    and_i_should_see_ucas_matches_statistics

    when_i_follow_the_link_to_ucas_match_for_a_candidate
    then_i_should_see_ucas_match_summary
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    @candidate = create(:candidate)
    @course1 = create(:course)
    course_option1 = create(:course_option, course: @course1)
    application_choice1 = create(:application_choice, :with_offer, course_option: course_option1)
    @course2 = create(:course)
    course_option2 = create(:course_option, course: @course2)
    application_choice2 = create(:submitted_application_choice, course_option: course_option2)
    @application_form = create(:application_form, candidate: @candidate, application_choices: [application_choice1, application_choice2])
  end

  def and_there_are_ucas_matches_in_the_system
    ucas_matching_data =
      {
        'Scheme' => 'B',
        'Apply candidate ID' => @candidate.id.to_s,
        'Course code' => @course1.code.to_s,
        'Provider code' => @course1.provider.code.to_s,
        'Withdrawns' => '1',
      }
    dfe_matching_data =
      {
        'Scheme' => 'D',
        'Apply candidate ID' => @candidate.id.to_s,
        'Course code' => @course2.code.to_s,
        'Provider code' => @course2.provider.code.to_s,
      }
    create(:ucas_match, matching_state: 'new_match', application_form: @application_form, matching_data: [ucas_matching_data, dfe_matching_data])
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_go_to_ucas_matches_page
    visit support_interface_ucas_matches_path
  end

  def then_i_should_see_list_of_ucas_matches
    expect(page).to have_content 'New match'
    expect(page).to have_content @candidate.email_address
  end

  def and_i_should_see_ucas_matches_statistics
    expect(page).to have_content 'Statistics'
    expect(page).to have_content '1 candidates on Apply in this cycle'
    expect(page).to have_content '1 (100%) candidates matched with UCAS, of which'
    expect(page).to have_content '0 (0% of candidates on Apply) have accepted Apply offers and have unwithdrawn UCAS application'
    expect(page).to have_content '1 (100% of candidates on Apply) have applied for the same course on both services'
  end

  def when_i_follow_the_link_to_ucas_match_for_a_candidate
    click_link @candidate.email_address
  end

  def then_i_should_see_ucas_match_summary
    expect(page).to have_content 'Matched courses'
    within('tbody tr:eq(1)') do
      expect(page).to have_content("#{@course1.code} — #{@course1.name} — #{@course1.provider.name}")
      expect(page).to have_content('Withdrawn')
      expect(page).to have_content('Offer made')
    end
    within('tbody tr:eq(2)') do
      expect(page).to have_content("#{@course2.code} — #{@course2.name} — #{@course2.provider.name}")
      expect(page).to have_content('N/A')
      expect(page).to have_content('Awaiting provider decision')
    end
    expect(page).to have_content('This applicant has applied to the same course on both services.')
  end
end
