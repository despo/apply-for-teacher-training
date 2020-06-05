require 'rails_helper'

RSpec.describe CandidateInterface::NewApplicationChoiceNeededBannerComponent do
  # if a course choice has been withdrawn or become full it shows
  # so withrawn? or no vacancies.
  describe '#render?' do
    context 'when a course has been withdrawn' do
      it 'renders the component' do
        application_form = create(:application_form, withdrawn: true)
        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context 'when a course has not been withdrawn' do
      it 'does not render the component' do
        application_form = create(:application_form, withdrawn: false)
        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end

    context 'when a course choice has become full' do
      it 'renders the component' do
        application_form = create(:application_form)
        create(:application_choice, vacancy_status: 'no_vacancies')

        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context 'when a course choice still has vacancies' do
      it 'does not render the component' do
        application_form = create(:application_form)
        create(:application_choice, vacancy_status: 'full_time')

        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end
  end
end
