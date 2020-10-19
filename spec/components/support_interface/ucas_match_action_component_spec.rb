require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchActionComponent do
  # let(:candidate) { create(:candidate) }
  # let(:course) { create(:course) }
  # let(:course_option) { create(:course_option, course: course) }
  # let(:application_choice) { create(:application_choice, :with_offer, course_option: course_option) }
  # let(:application_form) { create(:application_form, candidate: candidate, application_choices: [application_choice]) }
  let(:ucas_match_without_dual_applications) { create(:ucas_match, matching_state: 'new_match', scheme: 'U', ucas_status: :rejected) }
  let(:ucas_match_for_ucas_application) { create(:ucas_match, scheme: 'U', ucas_status: :rejected, application_form: application_form) }
  let(:ucas_match) { create(:ucas_match, scheme: 'B', ucas_status: :rejected, application_form: application_form) }
  let(:ucas_match_course_only_on_ucas) do
    create(:ucas_match,
           matching_data: [{
             'Scheme' => 'U',
             'Course code' => '123',
             'Course name' => 'Not on Apply',
             'Provider code' => course.provider.code.to_s,
             'Apply candidate ID' => candidate.id.to_s,
             'Withdrawns' => '1',
           }])
  end
  let(:ucas_match_for_welsh_provider) do
    create(:ucas_match,
           matching_data: [{
             'Scheme' => 'U',
             'Course code' => '',
             'Course name' => '',
             'Provider code' => 'T80',
             'Apply candidate ID' => candidate.id.to_s,
           }])
  end
  context 'when thes is no dual application or dual acceptance' do
    it 'renders `No action required`' do
      allow(ucas_match_without_dual_applications).to receive(:dual_application_or_dual_acceptance?).and_return(false)

      result = render_inline(described_class.new(ucas_match_without_dual_applications))
      expect(result.text).to include('No action required')
    end
  end

  context 'when thes is a dual application or dual acceptance' do
    it 'renders correct information for a new match' do
      ucas_match = create(:ucas_match, matching_state: 'new_match', scheme: 'U', candidate_last_contacted_at: nil)
      allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

      result = render_inline(described_class.new(ucas_match))

      expect(result.text).to include('Action needed Send initial emails')
      expect(result.css('input').attr('value').value).to include('Confirm initial emails were sent')
    end

    it 'renders correct information after sending the initial emails' do
      Timecop.freeze(Time.zone.local(2020, 9, 17, 12, 0, 0)) do
        ucas_match = create(:ucas_match, matching_state: 'initial_emails_sent', scheme: 'U', candidate_last_contacted_at: Time.zone.now - 1.day)
        allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)

        result = render_inline(described_class.new(ucas_match))

        expect(result.text).to include('No action required')
        expect(result.text).to include('We sent the initial emails on the ')
      end
    end
  end
end
