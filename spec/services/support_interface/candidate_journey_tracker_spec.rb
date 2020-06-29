require 'rails_helper'

RSpec.describe SupportInterface::CandidateJourneyTracker, with_audited: true do
  let(:now) { Time.zone.local(2020, 6, 6, 12, 30, 24) }

  around do |example|
    Timecop.freeze(now) { example.run }
  end

  describe '#form_not_started' do
    it 'returns time when the application was created' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).form_not_started).to eq now
    end
  end

  describe '#form_started_but_unsubmitted' do
    it 'returns the time when the application choice was created if the audit trail is empty' do
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 2))

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end

    it 'returns the time when the application form was first updated if this is recorded in the audit trail', audited: true do
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 7))
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq now
    end

    it 'returns the time when the application choice was created if this is earlier than any audit trail updated entries', audited: true do
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 5))
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end
  end

  describe '#submitted_and_awaiting_references' do
    it 'returns the time when the application form was submitted' do
      submitted_at = Time.zone.local(2020, 6, 2, 12, 10, 0)
      application_form = create(:application_form, submitted_at: submitted_at)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_and_awaiting_references).to eq submitted_at
    end

    it 'returns nil if the application form has not been submitted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_and_awaiting_references).to be_nil
    end
  end
end

# Form not started - created_at?
# Form started but unsubmitted - first audit trail update?
# Submiited & awaiting References - submitted_at
# Ref 1 recieved - from audit trail (reference status change)?
# Ref 2 recieved - from audit trail (reference status change)?
# Ref Reminder email sent - from chasers sent (chaser_type: :reference_request) (QUESTION: could be more than once)
# New ref req email sent - emails?
# New Ref added - ?
# References complete - from audit trail when `ApplicationForm#references_completed` gets set to true? (can happen more than once)
# Waiting to be sent to provider - not sure what this one means
# Application Sent to Provider - `ApplicationChoice#sent_to_provider_at`
# Awaiting Decision - not sure what this means (isn't it the same as `sent_to_provider_at`?)
# RBD Date - `ApplicationChoice#sent_to_provider_at`
# RBD Reminder Sent - Is this the `chase_provider_decision` email? `ChaserSent#provider_decision_request` ?
# Application RBD - Combination of `ApplicationChoice#rejected_at` and `rejected_by_default`
# Provider Decision (Reject/Offer) - `ApplicationChoice#rejected_at` or `ApplicationChoice#offered_at`
# Offer made, awaiting decision from candidate - `ApplicationChoice#offered_at`
# Email sent to candidate - the offer email? also the reject email?
# DBD Date - `ApplicationChoice#decline_by_default_at`
# DBD reminder email - `ChaserSent#chaser_type`
# Candidate Decision (accept/decline) - `ApplicationChoice#accepted_at` or `ApplicationChoice#declined_at`
# Offer declined - `ApplicationChoice#declined_at`
# Offer accepted - `ApplicationChoice#accepted_at`
# Email sent to candidate - the offer accepted email? QUESTION
# Pending Conditions - from audit trail
# Conditions Outcome - from audit trail
# Conditions Met - from audit trail
# Conditions Not Met - from audit trail
# Enrolled - from audit trail
# Ended without success - ?
# Send rejection email - emails?
