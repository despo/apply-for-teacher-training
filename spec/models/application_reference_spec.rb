require 'rails_helper'

RSpec.describe ApplicationReference, type: :model do
  subject { build(:reference) }

  describe 'saving a new reference' do
    context 'when there is no existing reference on the same application_form' do
      let!(:application_form) { create(:application_form) }
      let(:new_reference) { build(:reference, application_form: application_form) }

      it 'sets the ordinal to 1' do
        new_reference.save!
        expect(new_reference.ordinal).to eq(1)
      end
    end

    context 'when there is an existing reference on the same application_form' do
      let!(:application_form) { create(:application_form) }
      let(:new_reference) { build(:reference) }

      before do
        create(:reference, application_form: application_form)
        application_form.application_references << new_reference
      end

      it 'sets the ordinal to 2' do
        new_reference.save!
        expect(new_reference.ordinal).to eq(2)
      end
    end
  end

  # potential edge case: someone adds 2 references, then deletes the first
  # we want to make sure it updates the ordinal of the remaining second ref. to
  # be 1, so that we can still use that to describe 'First referee' etc in the
  # interface
  describe 'after deleting a reference' do
    let!(:application_form) { create(:completed_application_form, references_count: 2) }

    describe 'the ordinal of the remaining references' do
      let(:ordinals) { application_form.application_references.map(&:ordinal) }

      it 'still starts at 1' do
        application_form.application_references.first.destroy
        expect(ordinals.first).to eq(1)
      end
    end
  end

  describe 'auditing', with_audited: true do
    let(:application_form) { create(:application_form) }

    it { is_expected.to be_audited.associated_with :application_form }

    it 'creates an associated object in each audit record' do
      reference = create :reference, application_form: application_form
      expect(reference.audits.last.associated).to eq reference.application_form
    end

    it 'audit record can be attributed to a candidate' do
      candidate = create :candidate
      reference = Audited.audit_class.as_user(candidate) do
        create :reference, application_form: application_form
      end
      expect(reference.audits.last.user).to eq candidate
    end
  end
end
