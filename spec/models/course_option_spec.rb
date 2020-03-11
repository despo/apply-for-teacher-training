require 'rails_helper'

RSpec.describe CourseOption, type: :model do
  subject(:course_option) { create(:course_option) }

  describe 'a valid course option' do
    it { is_expected.to belong_to :course }
    it { is_expected.to belong_to :site }
    it { is_expected.to validate_presence_of :vacancy_status }

    context 'when site and course have different providers' do
      subject(:course_option) { build(:course_option, site: site_for_different_provider) }

      let(:site_for_different_provider) { create :site }

      it 'is not valid' do
        expect(course_option).not_to be_valid
        expect(course_option.errors.keys).to include(:site)
      end
    end
  end

  describe '#update_vacancy_status_from_detailed_description!' do
    context 'when study_mode is part_time' do
      let(:course_option) { create(:course_option, study_mode: :part_time) }

      [
        { description: 'no_vacancies', vacancy_status: 'no_vacancies' },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: 'vacancies' },
        { description: 'full_time_vacancies', vacancy_status: 'no_vacancies' },
        { description: 'part_time_vacancies', vacancy_status: 'vacancies' },
      ].each do |pair|
        it "sets #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          course_option.update_vacancy_status_from_detailed_description!(pair[:description])

          expect(course_option.vacancy_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          course_option.update_vacancy_status_from_detailed_description!('foo')
        }.to raise_error(CourseOption::InvalidVacancyStatusDescriptionError)
      end
    end

    context 'when study_mode is full_time' do
      let(:course_option) { create(:course_option, study_mode: :full_time) }

      [
        { description: 'no_vacancies', vacancy_status: 'no_vacancies' },
        { description: 'both_full_time_and_part_time_vacancies', vacancy_status: 'vacancies' },
        { description: 'full_time_vacancies', vacancy_status: 'vacancies' },
        { description: 'part_time_vacancies', vacancy_status: 'no_vacancies' },
      ].each do |pair|
        it "sets #{pair[:vacancy_status]} when description is #{pair[:description]}" do
          course_option.update_vacancy_status_from_detailed_description!(pair[:description])

          expect(course_option.vacancy_status).to eq pair[:vacancy_status]
        end
      end

      it 'raises an error when description is an unexpected value' do
        expect {
          course_option.update_vacancy_status_from_detailed_description!('foo')
        }.to raise_error(CourseOption::InvalidVacancyStatusDescriptionError)
      end
    end
  end
end
