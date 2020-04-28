require 'rails_helper'

# This is an end-to-end test for the API response. To test complex logic in
# the presenter, see spec/presenters/vendor_api/single_application_presenter_spec.rb.
RSpec.feature 'Vendor receives the application' do
  include CandidateHelper

  scenario 'A completed application is submitted with references' do
    Timecop.freeze do # simplify date assertions in the response
      given_a_candidate_has_submitted_their_application
      and_references_have_been_received
      and_the_edit_by_date_has_passed
      and_the_daily_application_cron_job_has_run

      when_i_retrieve_the_application_over_the_api
      then_it_should_include_the_data_from_the_application_form
    end
  end

  def given_a_candidate_has_submitted_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def and_references_have_been_received
    reference = @application.application_references.first

    reference.update!(
      feedback: 'My ideal person',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: reference,
    ).save!

    reference = @application.application_references.last

    reference.update!(
      feedback: 'Lovable',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def and_the_edit_by_date_has_passed
    @application.application_choices.first.update(edit_by: 1.minute.ago)
  end

  def and_the_daily_application_cron_job_has_run
    # TODO: Replace with a call to the outermost cron job, once it exists
    SendApplicationsToProvider.new.call
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = VendorAPIToken.create_with_random_token!(provider: @provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-01'

    @api_response = JSON.parse(page.body)
  end

  def then_it_should_include_the_data_from_the_application_form
    expected_attributes = {
      id: @provider.application_choices.first.id.to_s,
      type: 'application',
      attributes: {
        personal_statement: "Why do you want to become a teacher?: I believe I would be a first-rate teacher \n What is your subject knowledge?: Everything",
        interview_preferences: 'Not on a Wednesday',
        offer: nil,
        contact_details: {
          phone_number: '07700 900 982',
          address_line1: '42 Much Wow Street',
          address_line2: '',
          address_line3: 'London',
          address_line4: '',
          postcode: 'SW1P 3BT',
          country: 'GB',
          email: @current_candidate.email_address,
        },
        course: {
          recruitment_cycle_year: 2020,
          provider_code: '1N1',
          site_code: '-',
          course_code: '2XT2',
          study_mode: 'full_time',
        },
        candidate: {
          id: "C#{@current_candidate.id}",
          first_name: 'Lando',
          last_name: 'Calrissian',
          date_of_birth: '1937-04-06',
          nationality: %w[GB US],
          uk_residency_status: nil,
          english_main_language: true,
          other_languages:  "I'm great at Galactic Basic so English is a piece of cake",
          english_language_qualifications: '',
          disability_disclosure: 'I have difficulty climbing stairs',
        },
        qualifications: {
          gcses: [
            {
              id: @application.english_gcse.id,
              qualification_type: 'gcse',
              subject: 'english',
              grade: 'B',
              award_year: '1990',
              institution_details: nil,
              awarding_body: nil,
              equivalency_details: nil,
            },
            {
              id: @application.maths_gcse.id,
              qualification_type: 'gcse',
              subject: 'maths',
              grade: 'B',
              award_year: '1990',
              institution_details: nil,
              awarding_body: nil,
              equivalency_details: nil,
              },
            ],
         degrees: [
           {
              id: @application.qualification_in_subject(:degree, 'Doge').id,
              qualification_type: 'BA',
              subject: 'Doge',
              grade: 'first',
              award_year: '2009',
              institution_details: 'University of Much Wow',
              awarding_body: nil,
              equivalency_details: nil,
            },
          ],
         other_qualifications: [
           {
              id: @application.qualification_in_subject(:other, 'Believing in the Heart of the Cards').id,
              qualification_type: 'A level',
              subject: 'Believing in the Heart of the Cards',
              grade: 'A',
              award_year: '2015',
              institution_details: 'Yugi College',
              awarding_body: nil,
              equivalency_details: nil,
            },
          ],
          missing_gcses_explanation: 'Science GCSE or equivalent: I will sit the exam at my local college this summer.',
        },
        references: [
          {
            name: 'Terri Tudor',
            email: 'terri@example.com',
            relationship: 'Tutor',
            reference: 'My ideal person',
          },
          {
            name: 'Anne Other',
            email: 'anne@other.com',
            relationship: 'First boss',
            reference: 'Lovable',
          },
        ],
        rejection: nil,
        status: 'awaiting_provider_decision',
        phase: 'apply_1',
        submitted_at: @application.submitted_at.iso8601,
        updated_at: @application.application_choices.first.updated_at.iso8601,
        reject_by_default_at: @application.application_choices.first.reject_by_default_at.iso8601,
        withdrawal: nil,
        further_information: '',
        work_experience: {
          jobs: [
            {
              id: @application.application_work_experiences.first.id,
              start_date: '2014-05-01',
              end_date: '2019-01-01',
              role: 'Teacher',
              organisation_name: 'Oakleaf Primary School',
              working_with_children: false,
              commitment: 'part_time',
              description: "Working pattern: I had a working pattern\n\nDescription: I learned a lot about teaching",
            },
          ],
          volunteering: [
            {
              id: @application.application_volunteering_experiences.first.id,
              start_date: '2018-05-01',
              end_date: '2019-01-01',
              role: 'Classroom Volunteer',
              organisation_name: 'A Noice School',
              working_with_children: true,
              commitment: nil,
              description: 'I volunteered.',
            },
          ],
          work_history_break_explanation: 'I was unwell',
        },
      },
    }

    received_attributes = @api_response['data'].first.deep_symbolize_keys

    expect(received_attributes.deep_sort).to eq expected_attributes.deep_sort
  end
end
