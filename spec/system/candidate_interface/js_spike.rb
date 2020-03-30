require 'rails_helper'
require 'webmock'

RSpec.feature 'Spike JS test', js: true do
  include CandidateHelper

  scenario 'Test JS', driver: :rack_test do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_other_uk_qualification_option
    and_i_fill_in_the_type_of_qualification

    when_i_refresh_the_page
    i_should_see_some_js_magic
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
    WebMock.allow_net_connect! #this could go into a helper or something?
  end

  def and_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def when_i_select_other_uk_qualification_option
    choose('Other UK qualification')
  end

  def and_i_fill_in_the_type_of_qualification
    fill_in t('application_form.gcse.other_uk.label'), with: 'Scottish Baccalaureate'
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def i_should_see_some_js_magic
    #should pop up something
  end
end
