require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceForm do
  describe 'validations' do
    subject { described_class.new(application_form: build(:application_form)) }

    it { is_expected.to validate_presence_of :email_address }
    it { is_expected.to validate_length_of(:email_address).is_at_most(100) }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }

    it { is_expected.to allow_value(Faker::Lorem.sentence(word_count: 50)).for(:relationship) }
    it { is_expected.not_to allow_value(Faker::Lorem.sentence(word_count: 51)).for(:relationship) }

    it 'adds an error if the user tries to add the same email address twice' do
      application_form = create(:application_form)
      reference = create(:reference, application_form: application_form, email_address: 'one@example.com')
      form = described_class.new(application_form: application_form.reload)

      form.email_address = 'one@example.com'

      expect(form).not_to be_valid
      expect(form.errors.full_messages_for(:email_address)).to eq(
        ["Email address #{t('activemodel.errors.models.candidate_interface/reference_form.attributes.email_address.taken')}"],
      )
    end

    it 'adds an error if the user tries to add the use their own email address' do
      application_form = create(:application_form)
      form = described_class.new(application_form: application_form.reload)

      form.email_address = application_form.candidate.email_address

      expect(form).not_to be_valid
      expect(form.errors.full_messages_for(:email_address)).to eq(
        ["Email address #{t('activemodel.errors.models.candidate_interface/reference_form.attributes.email_address.own')}"],
      )
    end
  end
end
