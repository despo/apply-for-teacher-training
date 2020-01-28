require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send submit application email' do
    let(:candidate) { build_stubbed(:candidate) }
    let(:application_form) { build_stubbed(:application_form, support_reference: 'SUPPORT-REFERENCE', candidate: candidate) }
    let(:mail) { mailer.submit_application_email(application_form) }

    before do
      allow(Encryptor).to receive(:encrypt).with(candidate.id).and_return('example_encrypted_id')
      mail.deliver_later
    end

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('submit_application_success.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include('Application submitted')
    end

    it 'sends an email containing the support reference' do
      expect(mail.body.encoded).to include('SUPPORT-REFERENCE')
    end

    context 'when the improved_expired_token_flow feature flag is on' do
      before { FeatureFlag.activate('improved_expired_token_flow') }

      it 'sends an email containing a link to sign in and id' do
        expect(mail.body.encoded).to include(candidate_interface_sign_in_url(u: 'example_encrypted_id'))
      end
    end

    context 'when the improved_expired_token_flow feature flag is off' do
      before { FeatureFlag.deactivate('improved_expired_token_flow') }

      it 'sends an email containing a link to sign in without id' do
        expect(mail.body.encoded).to include(candidate_interface_sign_in_url)
        expect(mail.body.encoded).not_to include(candidate_interface_sign_in_url(u: 'example_encrypted_id'))
      end
    end
  end

  describe 'Send reference chaser email' do
    let(:application_form) { create(:completed_application_form, references_count: 1, with_gces: true) }
    let(:reference) { application_form.application_references.first }
    let(:mail) { mailer.reference_chaser_email(application_form, reference) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('candidate_reference.subject.chaser', referee_name: reference.name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
    end

    it 'sends an email containing the referee email' do
      expect(mail.body.encoded).to include(reference.email_address)
    end
  end

  describe 'Send survey email' do
    let(:application_form) { build_stubbed(:application_form) }

    context 'when initial email' do
      let(:mail) { mailer.survey_email(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.initial'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
      end

      it 'sends an email with the correct thank you message' do
        expect(mail.body.encoded).to include(t('survey_emails.thank_you.candidate'))
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end

    context 'when chaser email' do
      let(:mail) { mailer.survey_chaser_email(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.chaser'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end
  end

  describe 'Send request for new referee email' do
    let(:reference) { build_stubbed(:reference, name: 'Scott Knowles') }
    let(:application_form) do
      build_stubbed(
        :application_form,
        first_name: 'Tyrell',
        last_name: 'Wellick',
        application_references: [reference],
      )
    end

    context 'when referee has not responded' do
      let(:mail) { mailer.new_referee_request(application_form, reference) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.not_responded.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee has not responded' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.not_responded.explanation', referee_name: 'Scott Knowles'))
      end
    end

    context 'when referee has refused' do
      let(:mail) { mailer.new_referee_request(application_form, reference, reason: :refused) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.refused.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee has refused' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.refused.explanation', referee_name: 'Scott Knowles'))
      end
    end

    context 'when email address of referee has bounced' do
      let(:mail) { mailer.new_referee_request(application_form, reference, reason: :email_bounced) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include('Dear Tyrell')
      end

      it 'sends an email saying referee email bounced' do
        explanation = mail.body.encoded.gsub("\r", '')

        expect(explanation).to include(t('new_referee_request.email_bounced.explanation', referee_name: 'Scott Knowles', referee_email: reference.email_address))
      end
    end
  end
end
