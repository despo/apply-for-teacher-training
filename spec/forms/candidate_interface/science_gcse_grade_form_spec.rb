require 'rails_helper'

RSpec.describe CandidateInterface::ScienceGcseGradeForm, type: :model do
  describe 'validations' do
    before { FeatureFlag.deactivate(:international_gcses) }

    it { is_expected.to validate_presence_of(:grade).on(:grade) }
    it { is_expected.to validate_length_of(:grade).is_at_most(6).on(:grade) }

    context 'when grade is "other"' do
      let(:form) { subject }

      before { allow(form).to receive(:grade_is_other?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

    context 'when qualification type is GCSE' do
      context 'single or double award' do
        let(:form) { CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification) }
        let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'gcse', level: 'gcse') }

        it 'returns no errors if grade is valid' do
          valid_grades = ['A*A*A*', 'ABC', 'AA', '863', 'a*a*a*', 'A B C', 'A-B-C']

          valid_grades.each do |grade|
            form.grade = grade
            form.validate

            expect(form.errors[:grade]).to be_empty
          end
        end

        it 'return validation error if grade is invalid' do
          invalid_grades = %w[012 XYZ]

          invalid_grades.each do |grade|
            form.grade = grade
            form.validate(:grade)

            expect(form.errors[:grade]).to include('Enter a real grade')
          end
        end

        it 'logs validation errors if grade is invalid' do
          allow(Rails.logger).to receive(:info)
          form.grade = 'XYZ'

          form.save_grades

          expect(Rails.logger).to have_received(:info).with(
            'Validation error: {:field=>"grade", :error_messages=>"Enter a real grade", :value=>"XYZ"}',
          )
        end
      end

      context 'triple award' do
        let(:qualification) do
          FactoryBot.build_stubbed(
            :application_qualification,
            qualification_type: 'gcse',
            level: 'gcse',
          )
        end
        let(:form) { CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification) }

        it 'returns no errors if all grades are valid' do
          form.subject = ApplicationQualification::SCIENCE_TRIPLE_AWARD

          valid_grades = ['A*', 'A', '8']

          valid_grades.each do |grade|
            form.biology_grade = grade
            form.chemistry_grade = grade
            form.physics_grade = grade
            form.validate

            expect(form.errors[:grades]).to be_empty
          end
        end

        it 'return validation error if one or more grades are invalid' do
          form.subject = ApplicationQualification::SCIENCE_TRIPLE_AWARD

          invalid_grades = %w[XYZ]

          invalid_grades.each do |invalid_grade|
            form.biology_grade = invalid_grade
            form.chemistry_grade = 'A'
            form.physics_grade = 'A'

            form.validate(:grade)

            expect(form.errors[:biology_grade]).to include('Enter a real grade')
          end
        end
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      let(:form) { CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification) }
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'gce_o_level', level: 'gcse') }

      it 'returns no errors if grade is valid' do
        valid_grades = ['ABC', 'AB', 'AA', 'abc', 'A B C', 'A-B-C']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[123 A* XYZ]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end
    end

    context 'when qualification type is Scottish National 5' do
      let(:form) { CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification) }
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'scottish_national_5', level: 'gcse') }

      it 'returns no errors if grade is valid' do
        valid_grades = ['AAA', 'AAB', '765', 'CBD', 'aaa', 'C B D', 'C-B-D']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[89 AE A*]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end
    end
  end

  context 'when saving qualification details' do
    qualification = ApplicationQualification.new
    form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

    describe '#save_grades' do
      it 'return false if not valid' do
        expect(form.save_grades).to eq(false)
      end

      it 'updates qualification details if valid' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

        details_form.grade = 'AB'

        details_form.save_grades
        qualification.reload

        expect(qualification.grade).to eq('AB')
      end

      it 'sets grade to other_grade if candidate selected "other"' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

        details_form.grade = 'other'
        details_form.other_grade = 'D'

        details_form.save_grades
        qualification.reload

        expect(qualification.grade).to eq('D')
      end
    end

    describe '.build_from_qualification' do
      context 'with the international_gcses feature flag off' do
        let(:data) do
          {
            grade: 'other',
          }
        end

        it 'creates an object based on the provided ApplicationForm' do
          qualification = ApplicationQualification.new(data)
          gcse_details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

          expect(gcse_details_form).to have_attributes(data)
        end
      end

      context 'with the international_gcses feature flag on, the qualification_type is non_uk and grade is not_applicable' do
        it 'sets grade to not_applicable and other grade to nil' do
          FeatureFlag.activate('international_gcses')
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'n/a')
          gcse_details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'not_applicable'
          expect(gcse_details_form.other_grade).to eq nil
        end
      end

      context 'with the international_gcses feature flag on and grade is unknown' do
        it 'sets grade to not_applicable and other grade to nil' do
          FeatureFlag.activate('international_gcses')
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'unknown')
          gcse_details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'unknown'
          expect(gcse_details_form.other_grade).to eq nil
        end
      end

      context 'with the international_gcses feature flag on and grade is another value' do
        it 'sets grade to other and other grade to grades value' do
          FeatureFlag.activate('international_gcses')
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'D')
          gcse_details_form = CandidateInterface::ScienceGcseGradeForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'other'
          expect(gcse_details_form.other_grade).to eq 'D'
        end
      end
    end
  end
end
