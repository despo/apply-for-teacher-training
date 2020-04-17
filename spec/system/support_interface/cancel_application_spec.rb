require 'rails_helper'

RSpec.feature 'Cancel an application' do
  include DfESignInHelpers

  scenario 'A support user cancels an entire application' do
    given_i_am_a_support_user
    and_there_is_a_candidate_who_wants_to_cancel_their_application
    when_i_visit_the_application_form
    and_click_on_the_button_to_change_courses
    and_i_select_the_option_to_cancel_the_application
    and_i_confirm_the_cancellation

    then_the_application_is_cancelled
    and_the_references_are_cancelled
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_candidate_who_wants_to_cancel_their_application
    @application_form = create(:completed_application_form)
    create(:reference, application_form: @application_form)

    create(:application_choice, status: 'awaiting_references', application_form: @application_form)
    create(:application_choice, status: 'awaiting_references', application_form: @application_form)
  end

  def when_i_visit_the_application_form
    visit support_interface_application_form_path(@application_form)
  end

  def and_click_on_the_button_to_change_courses
    click_on 'Make changes to courses'
  end

  def and_i_select_the_option_to_cancel_the_application
    choose 'Cancel all courses and cancel application'
    click_on 'Continue'
  end

  def and_i_confirm_the_cancellation
    click_on 'Confirm'
  end

  def then_the_application_is_cancelled
    # TODO once the other PR is merged
  end

  def and_the_references_are_cancelled
    expect(page).to have_content 'Reference status Cancelled'
  end
end
