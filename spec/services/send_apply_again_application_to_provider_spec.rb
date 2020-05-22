require 'rails_helper'

RSpec.describe SendApplyAgainApplicationToProvider do
  let!(:application_form) { create(:completed_application_form, application_choices: [application_choice1, application_choice2, application_choice3]) }
  let(:application_choice1) { build(:application_choice) }
  let(:application_choice2) { build(:application_choice) }
  let(:application_choice3) { build(:application_choice) }
  let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
  let(:send_applications_service) { instance_double(SendApplicationToProvider, call: true) }

  before do
    allow(SendApplicationToProvider).to receive(:new).and_return(send_applications_service)
    allow(CandidateMailer).to receive(:application_sent_to_provider).and_return(mail)
    described_class.call(application_form: application_form)
  end

  it 'calls the SendApplicationToProvider service for each application choice' do
    expect(SendApplicationToProvider).to have_received(:new).exactly(1).times.with(application_choice: application_choice1)
    expect(SendApplicationToProvider).to have_received(:new).exactly(1).times.with(application_choice: application_choice2)
    expect(SendApplicationToProvider).to have_received(:new).exactly(1).times.with(application_choice: application_choice3)
  end

  it 'sends the candidate an email to inform them their application has been sent to their providers' do
    expect(CandidateMailer).to have_received(:application_sent_to_provider).with(application_form)
  end
end
