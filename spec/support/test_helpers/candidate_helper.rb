module CandidateHelper
  APPLICATION_FORM_SECTIONS = %i[
    course_choices
    personal_details
    contact_details
    training_with_a_disability
    safeguarding
    work_experience
    volunteering
    degrees
    maths_gcse
    english_gcse
    science_gcse
    efl
    becoming_a_teacher
    subject_knowledge
    interview_preferences
    references
  ].freeze

  def create_and_sign_in_candidate
    login_as(current_candidate)
  end

  def candidate_completes_application_form
    FeatureFlag.deactivate(:international_addresses)
    FeatureFlag.deactivate(:international_personal_details)
    FeatureFlag.deactivate(:efl_section)
    FeatureFlag.deactivate(:international_degrees)

    given_courses_exist
    create_and_sign_in_candidate
    visit candidate_interface_application_form_path

    click_link 'Course choices'
    candidate_fills_in_course_choices

    click_link t('page_titles.personal_details')
    candidate_fills_in_personal_details

    click_link t('page_titles.contact_details')
    visit candidate_interface_contact_details_edit_base_path
    candidate_fills_in_contact_details

    click_link t('page_titles.work_history')
    candidate_fills_in_work_experience

    click_link t('page_titles.volunteering.short')
    candidate_fills_in_volunteering_role

    click_link t('page_titles.training_with_a_disability')
    candidate_fills_in_disability_info

    click_link t('page_titles.suitability_to_work_with_children')
    candidate_fills_in_safeguarding_issues

    click_link t('page_titles.degree')
    candidate_fills_in_their_degree

    click_link 'Maths GCSE or equivalent'
    candidate_fills_in_a_gcse

    click_link 'English GCSE or equivalent'
    candidate_fills_in_a_gcse

    click_link 'Science GCSE or equivalent'
    candidate_explains_a_missing_gcse

    click_link 'Academic and other relevant qualifications'
    candidate_fills_in_their_other_qualifications

    click_link 'Why do you want to be a teacher?'
    candidate_fills_in_becoming_a_teacher

    click_link 'What do you know about the subject you want to teach?'
    candidate_fills_in_subject_knowledge

    click_link t('page_titles.interview_preferences')
    candidate_fills_in_interview_preferences

    candidate_provides_two_referees

    @application = ApplicationForm.last
  end

  def candidate_submits_application
    receive_references if FeatureFlag.active?(:decoupled_references)

    click_link 'Check and submit your application'
    click_link 'Continue'
    click_link 'Continue without completing questionnaire'
    choose 'No' # "Is there anything else you would like to tell us?"

    click_button(FeatureFlag.active?(:decoupled_references) ? 'Send application' : 'Submit application')
    @application = ApplicationForm.last
  end

  def receive_references
    application_form = ApplicationForm.last
    first_reference = application_form.application_references.first

    first_reference.update!(
      feedback: 'My ideal person',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: first_reference,
    ).save!

    second_reference = application_form.application_references.last

    second_reference.update!(
      feedback: 'Lovable',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: second_reference,
    ).save!
  end

  def given_courses_exist
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: @provider)
    course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: site, course: course)
  end

  def candidate_fills_in_course_choices
    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    choose 'Primary (2XT2)'
    click_button 'Continue'

    choose 'No, not at the moment'
    click_button 'Continue'

    check t('application_form.courses.complete.completed_checkbox')
    click_button 'Continue'
  end

  def candidate_fills_in_personal_details
    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('complete_form_button', scope: scope)

    select('British', from: t('nationality.label', scope: scope))
    find('details').click
    within('details') do
      select('American', from: t('second_nationality.label', scope: scope))
    end
    click_button t('complete_form_button', scope: scope)

    choose 'Yes'
    fill_in t('english_main_language.yes_label', scope: scope), with: "I'm great at Galactic Basic so English is a piece of cake", match: :prefer_exact
    click_button t('complete_form_button', scope: scope)
    check t('application_form.completed_checkbox')
    click_button 'Continue'
  end

  def candidate_fills_in_contact_details
    fill_in t('application_form.contact_details.phone_number.label'), with: '07700 900 982'
    click_button t('application_form.contact_details.base.button')

    find(:css, "[autocomplete='address-line1']").fill_in with: '42 Much Wow Street'
    fill_in t('application_form.contact_details.address_line3.label'), with: 'London'
    fill_in t('application_form.contact_details.postcode.label'), with: 'SW1P 3BT'
    click_button t('application_form.contact_details.address.button')

    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_their_degree
    visit candidate_interface_new_degree_path

    fill_in 'Type of degree', with: 'BA'
    click_button t('application_form.degree.base.button')

    fill_in 'What subject is your degree?', with: 'Doge'
    click_button t('application_form.degree.base.button')

    fill_in 'Which institution did you study at?', with: 'University of Much Wow'
    click_button t('application_form.degree.base.button')

    choose 'First class honours'
    click_button t('application_form.degree.base.button')

    year_with_trailing_space = '2006 '
    year_with_preceding_space = ' 2009'
    fill_in 'Year started course', with: year_with_trailing_space
    fill_in 'Graduation year', with: year_with_preceding_space
    click_button t('application_form.degree.base.button')
    check t('application_form.degree.review.completed_checkbox')
    click_button t('application_form.degree.review.button')
  end

  def candidate_fills_in_their_other_qualifications
    choose 'A level'
    click_button 'Continue'
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
    choose 'No, not at the moment'
    click_button t('application_form.other_qualification.base.button')
    check t('application_form.other_qualification.review.completed_checkbox')
    click_button t('application_form.other_qualification.review.button')
  end

  def candidate_fills_in_disability_info
    choose t('application_form.training_with_a_disability.disclose_disability.yes')
    fill_in t('application_form.training_with_a_disability.disability_disclosure.label'), with: 'I have difficulty climbing stairs'
    click_button t('application_form.training_with_a_disability.complete_form_button')
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_safeguarding_issues
    choose 'Yes'
    fill_in 'Give any relevant information', with: 'I have a criminal conviction.'
    click_button 'Continue'
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_work_experience
    choose t('application_form.work_history.more_than_5.label')
    click_button 'Continue'

    with_options scope: 'application_form.work_history' do |locale|
      fill_in locale.t('role.label'), with: 'Teacher'
      fill_in locale.t('organisation.label'), with: 'Oakleaf Primary School'
      choose 'Part-time'

      fill_in 'Give details about your working pattern', with: 'I had a working pattern'

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2014'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      fill_in locale.t('details.label'), with: 'I learned a lot about teaching'

      choose 'No'
      choose 'No, not at the moment'
    end

    click_button t('application_form.work_history.complete_form_button')
    check t('application_form.work_history.review.completed_checkbox')
    click_button t('application_form.work_history.review.button')
  end

  def candidate_fills_in_volunteering_role
    choose 'Yes' # "Do you have experience volunteering with young people or in school?"
    click_button t('application_form.volunteering.experience.button')

    with_options scope: 'application_form.volunteering' do |locale|
      fill_in locale.t('role.label'), with: 'Classroom Volunteer'
      fill_in locale.t('organisation.label'), with: 'A Noice School'

      choose 'Yes'

      within('[data-qa="start-date"]') do
        fill_in 'Month', with: '5'
        fill_in 'Year', with: '2018'
      end

      within('[data-qa="end-date"]') do
        fill_in 'Month', with: '1'
        fill_in 'Year', with: '2019'
      end

      fill_in locale.t('details.label'), with: 'I volunteered.'
    end

    click_button t('application_form.volunteering.complete_form_button')
    check t('application_form.volunteering.review.completed_checkbox')
    click_button t('application_form.volunteering.review.button')
  end

  def candidate_fills_in_referee(params = {})
    if FeatureFlag.active?(:decoupled_references)
      fill_in t('application_form.references.name.label'), with: params[:name] || 'Terri Tudor'
      click_button 'Save and continue'
      fill_in t('application_form.references.email_address.label'), with: params[:email_address] || 'terri@example.com'
      click_button 'Save and continue'
      fill_in t('application_form.references.relationship.label'), with: params[:relationship] || 'Tutor'
      click_button 'Save and continue'
    else
      fill_in t('application_form.referees.name.label'), with: params[:name] || 'Terri Tudor'
      fill_in t('application_form.referees.email_address.label'), with: params[:email_address] || 'terri@example.com'
      fill_in t('application_form.referees.relationship.label'), with: params[:relationship] || 'Tutor'
    end
  end

  def candidate_provides_two_referees
    if FeatureFlag.active?(:decoupled_references)
      visit candidate_interface_decoupled_references_start_path
      click_link 'Continue'
      choose 'Academic'
      click_button 'Save and continue'

      candidate_fills_in_referee
      choose 'Yes, send a reference request now'
      click_button 'Save and continue'

      click_link 'Add another referee'
      click_link 'Continue'
      choose 'Professional'
      click_button 'Save and continue'

      candidate_fills_in_referee(
        name: 'Anne Other',
        email_address: 'anne@other.com',
        relationship: 'First boss',
      )
      choose 'Yes, send a reference request now'
      click_button 'Save and continue'
      visit candidate_interface_application_form_path
    else
      visit candidate_interface_referees_type_path
      choose 'Academic'
      click_button 'Continue'

      candidate_fills_in_referee
      click_button 'Save and continue'
      click_link 'Add another referee'

      choose 'Professional'
      click_button 'Continue'

      candidate_fills_in_referee(
        name: 'Anne Other',
        email_address: 'anne@other.com',
        relationship: 'First boss',
      )
      click_button 'Save and continue'
      check t('application_form.completed_checkbox')
      click_button t('application_form.continue')
    end
  end

  def candidate_fills_in_a_gcse
    choose('GCSE')
    click_button 'Save and continue'
    select 'B', from: 'Grade'
    click_button 'Save and continue'
    fill_in 'Enter year', with: '1990'
    click_button 'Save and continue'
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_explains_a_missing_gcse
    choose('I do not have this qualification yet')
    fill_in t('application_form.gcse.missing_explanation.label'), with: 'I will sit the exam at my local college this summer.'
    click_button 'Save and continue'
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_becoming_a_teacher
    fill_in t('application_form.personal_statement.becoming_a_teacher.label'), with: 'I believe I would be a first-rate teacher'
    click_button t('application_form.personal_statement.becoming_a_teacher.complete_form_button')
    # Confirmation page
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_subject_knowledge
    fill_in t('application_form.personal_statement.subject_knowledge.label'), with: 'Everything'
    click_button t('application_form.personal_statement.subject_knowledge.complete_form_button')
    # Confirmation page
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def candidate_fills_in_interview_preferences
    choose 'Yes'
    fill_in t('application_form.personal_statement.interview_preferences.yes_label'), with: 'Not on a Wednesday'
    click_button t('application_form.personal_statement.interview_preferences.complete_form_button')
    # Confirmation page
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def current_candidate
    @current_candidate ||= create(:candidate)
  end
end
