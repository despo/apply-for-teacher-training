require 'rails_helper'

RSpec.describe UCASMatchedApplication do
  let(:course) { create(:course) }
  let(:candidate) { create(:candidate) }
  let(:course_option) { create(:course_option, course: course) }
  let(:application_choice) { create(:application_choice, :with_accepted_offer, course_option: course_option) }
  let(:application_form) { create(:completed_application_form, candidate_id: candidate.id, application_choices: [application_choice]) }
  let(:candidate1) { create(:candidate) }
  let(:application_choice1) { create(:application_choice, :with_offer, course_option: course_option) }
  let(:application_form1) { create(:completed_application_form, candidate_id: candidate1.id, application_choices: [application_choice1]) }

  before do
    application_form
    application_form1
  end

  describe '#course' do
    it 'returns the course' do
      ucas_matching_data =
        { 'Course code' => course.code.to_s,
          'Provider code' => course.provider.code.to_s,
          'Apply candidate ID' => candidate.id.to_s }
      ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

      expect(ucas_matching_application.course).to eq(course)
    end
  end

  describe '#status' do
    context 'when it is a DfE match' do
      it 'returns the applications status' do
        dfe_matching_data =
          { 'Scheme' => 'D',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(dfe_matching_data)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end

    context 'when it is a UCAS match' do
      it 'returns the applications status' do
        ucas_matching_data =
          { 'Scheme' => 'U',
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.status).to eq('rejected')
        expect(ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.map(&:to_s)).to include(ucas_matching_application.status)
      end
    end

    context 'when it is a match on both systems' do
      it 'returns the applications status on apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s,
            'Offers' => '.',
            'Rejects' => '1',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.status).to eq(application_choice.status)
      end
    end

    describe '#accepted_on_apply?' do
      it 'returns true if application is in accepted state on Apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.accepted_on_apply?).to eq(true)
      end

      it 'retruns false if application is not in accepted state on Apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate1.id.to_s }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.accepted_on_apply?).to eq(false)
      end
    end

    describe '#unwithdrawn_from_ucas?' do
      it 'retruns true if application is in accepted state on Apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate.id.to_s,
            'Offers' => '1',
            'Rejects' => '.',
            'Withdrawns' => '.',
            'Applications' => '.',
            'Unconditional firm' => '1',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.unwithdrawn_from_ucas?).to eq(true)
      end

      it 'retruns false if application is not in accepted state on Apply' do
        ucas_matching_data =
          { 'Scheme' => 'B',
            'Course code' => course.code.to_s,
            'Provider code' => course.provider.code.to_s,
            'Apply candidate ID' => candidate1.id.to_s,
            'Offers' => '.',
            'Rejects' => '.',
            'Withdrawns' => '1',
            'Applications' => '.',
            'Unconditional firm' => '.',
            'Applicant withdrawn entirely from scheme' => '.',
            'Applicant withdrawn from scheme while offer awaiting applicant reply' => '.',
            'Applicant withdrawn from scheme after firmly accepting a conditional offer' => '.',
            'Applicant withdrawn from scheme after firmly accepting an unconditional offer' => '.' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.unwithdrawn_from_ucas?).to eq(false)
      end

      it 'retruns false the application is DFE scheme' do
        ucas_matching_data = { 'Scheme' => 'D' }
        ucas_matching_application = UCASMatchedApplication.new(ucas_matching_data)

        expect(ucas_matching_application.unwithdrawn_from_ucas?).to eq(false)
      end
    end
  end
end
