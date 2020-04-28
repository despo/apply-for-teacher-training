require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationForm, type: :model do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_form.attributes.'
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:institution_name) }
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }

    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
    it { is_expected.to validate_length_of(:institution_name).is_at_most(255) }
    it { is_expected.to validate_length_of(:grade).is_at_most(255) }

    describe 'award year' do
      it 'is valid if the award year is 4 digits' do
        qualification = CandidateInterface::OtherQualificationForm.new(award_year: '2009')

        qualification.validate

        expect(qualification.errors.full_messages_for(:award_year)).to be_empty
      end

      ['a year', '200'].each do |invalid_date|
        it "is invalid if the award year is '#{invalid_date}'" do
          qualification = CandidateInterface::OtherQualificationForm.new(award_year: invalid_date)
          error_message = t('award_year.invalid', scope: error_message_scope)

          qualification.validate

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ["Award year #{error_message}"],
          )
        end
      end

      it 'is invalid if the award year is in the future' do
        Timecop.freeze(Time.zone.local(2019, 10, 1, 12, 0, 0)) do
          qualification = CandidateInterface::OtherQualificationForm.new(award_year: '2029')

          qualification.validate

          expect(qualification.errors.full_messages_for(:award_year)).to eq(
            ['Award year Enter a year before 2020'],
          )
        end
      end
    end
  end

  describe '.build_all_from_application' do
    let(:application_form) do
      create(:application_form) do |form|
        form.application_qualifications.create(
          level: 'other',
          created_at: DateTime.new(2019, 1, 1, 1, 9, 0, 0),
        )
        form.application_qualifications.create(
          level: 'other',
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          institution_name: 'School of Heroes',
          grade: 'Distinction',
          predicted_grade: false,
          award_year: '2012',
          created_at: DateTime.new(2019, 1, 1, 21, 0, 0),
        )
        form.application_qualifications.create(level: 'degree')
        form.application_qualifications.create(level: 'gcse')
      end
    end

    it 'creates an array of objects based on the provided ApplicationForm' do
      qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(application_form)

      expect(qualifications).to include(
        have_attributes(
          qualification_type: 'BTEC',
          subject: 'Being a Superhero',
          institution_name: 'School of Heroes',
          grade: 'Distinction',
          award_year: '2012',
        ),
      )
    end

    it 'only includes other qualifications and not degrees or GCSEs' do
      qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(application_form)

      expect(qualifications.count).to eq(2)
    end

    it 'orders other qualifications by created at' do
      qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(application_form)

      expect(qualifications.last).to have_attributes(
        qualification_type: 'BTEC',
        subject: 'Being a Superhero',
      )
    end
  end

  describe '.build_from_qualification' do
    it 'returns a new OtherQualificationForm object using an application qualification' do
      application_qualification = build_stubbed(
        :application_qualification,
        level: 'other',
        qualification_type: 'BTEC',
        subject: 'Being a Sidekick',
        institution_name: 'School of Sidekicks',
        grade: 'Merit',
        predicted_grade: false,
        award_year: '2010',
      )

      qualification = CandidateInterface::OtherQualificationForm.build_from_qualification(application_qualification)

      expect(qualification).to have_attributes(qualification_type: 'BTEC', subject: 'Being a Sidekick')
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      qualification = CandidateInterface::OtherQualificationForm.new

      expect(qualification.save).to eq(false)
    end

    it 'saves the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      application_qualification = create(:other_qualification, application_form: application_form)
      form_data = {
        id: application_qualification.id,
        qualification_type: 'BTEC',
        subject: 'Being a Superhero',
        institution_name: 'School of Heroes',
        grade: 'Distinction',
        award_year: '2012',
      }
      qualification = CandidateInterface::OtherQualificationForm.new(form_data)

      expect(qualification.save).to eq(true)
      expect(application_form.application_qualifications.other.first)
        .to have_attributes(form_data)
    end
  end

  describe '#update' do
    it 'returns false if not valid' do
      qualification = CandidateInterface::OtherQualificationForm.new

      expect(qualification.update(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)

      existing_qualification = application_form.application_qualifications.create(
        level: 'other',
        qualification_type: 'BTEC',
        subject: 'Being a Everyday Hero',
        institution_name: 'School of Hoomans',
        grade: 'Pass',
        predicted_grade: false,
        award_year: '2011',
      )

      form_data = {
        id: existing_qualification.id,
        qualification_type: 'BTEC',
        subject: 'Being a Everyday Hero',
        institution_name: 'School of Humans',
        grade: 'Distinction',
        award_year: '2011',
      }
      qualification_form = CandidateInterface::OtherQualificationForm.new(form_data)

      expect(qualification_form.update(application_form)).to eq(true)
      expect(application_form.application_qualifications.other.first)
        .to have_attributes(form_data)
    end
  end

  describe '#title' do
    it 'concatenates the qualification type and subject' do
      qualification = CandidateInterface::OtherQualificationForm.new(qualification_type: 'BTEC', subject: 'Being a Supervillain')

      expect(qualification.title).to eq('BTEC Being a Supervillain')
    end
  end
end
