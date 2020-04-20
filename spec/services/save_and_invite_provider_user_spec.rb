require 'rails_helper'

RSpec.describe SaveAndInviteProviderUser do
  let(:provider) { create(:provider) }
  let(:form) {
    SupportInterface::ProviderUserForm.new(
      email_address: 'test+invite_provider_user@example.com',
      first_name: 'Firstname',
      last_name: 'Lastname',
      provider_ids: [provider.id],
    )
  }
  let(:permissions) { { manage_users: [provider.id] } }
  let(:provider_user) { form.build }
  let(:save_service) { instance_double(SaveProviderUser, call!: true) }
  let(:invite_service) { instance_double(InviteProviderUser, call!: true) }

  describe '#initialize' do
    it 'requires a form, create service and invite service' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect {
        described_class.new(form: form, save_service: save_service, invite_service: invite_service)
      }.not_to raise_error
    end
  end

  describe '#call!' do
    subject(:service) do
      described_class.new(form: form, save_service: save_service, invite_service: invite_service)
    end

    context 'an error occurs in create service' do
      before do
        allow(save_service).to receive(:call!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'exits the transactioni and raises the error' do
        expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)

        expect(invite_service).not_to have_received(:call!)
      end
    end

    context 'an error occurs in invite service' do
      before { allow(invite_service).to receive(:call!).and_raise }

      it 'rolls back the transaction and raises the error' do
        expect { service.call }.to raise_error.and change(ProviderUser, :count).by(0)
      end
    end

    context 'a DfeSignInApiError occurs' do
      before { allow(invite_service).to receive(:call!).and_raise(DfeSignInApiError) }

      it 'rolls back the transaction' do
        expect { service.call }.not_to change(ProviderUser, :count)
      end

      it 'populates form errors' do
        service.call

        expect(service.form.errors).not_to be_empty
      end
    end
  end
end