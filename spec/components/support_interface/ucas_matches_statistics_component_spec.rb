require 'rails_helper'

RSpec.describe SupportInterface::UCASMatchesStatisticsComponent do
  let(:candidate1) { create(:candidate) }
  let(:course1) { create(:course) }
  let(:course_option1) { create(:course_option, course: course1) }
  let(:application_choice1) { create(:application_choice, :with_offer, course_option: course_option1) }
  let(:application_form1) { create(:application_form, candidate: candidate1, application_choices: [application_choice1]) }

  let(:candidate2) { create(:candidate) }
  let(:course2) { create(:course) }
  let(:course_option2) { create(:course_option, course: course2) }
  let(:application_choice2) { create(:application_choice, :with_accepted_offer, course_option: course_option2) }
  let(:application_form2) { create(:application_form, candidate: candidate2, application_choices: [application_choice2]) }

  let(:candidate3) { create(:candidate) }
  let(:course3) { create(:course) }
  let(:course_option3) { create(:course_option, course: course3) }
  let(:application_choice3) { create(:application_choice, :with_accepted_offer, course_option: course_option3) }
  let(:application_form3) { create(:application_form, candidate: candidate3, application_choices: [application_choice3]) }

  let(:not_matched_candidate) { create(:candidate) }
  let(:course4) { create(:course) }
  let(:course_option4) { create(:course_option, course: course4) }
  let(:application_choice4) { create(:application_choice, :with_offer, course_option: course_option4) }
  let(:application_form4) { create(:application_form, candidate: not_matched_candidate, application_choices: [application_choice4]) }

  let(:dfe_matching_data) do
    {
      'Scheme' => 'D',
      'Apply candidate ID' => candidate2.id.to_s,
      'Course code' => course2.code.to_s,
      'Provider code' => course2.provider.code.to_s,
    }
  end
  let(:ucas_unwithdrawn_matching_data) do
    {
      'Scheme' => 'U',
      'Apply candidate ID' => candidate2.id.to_s,
      'Course code' => course1.code.to_s,
      'Provider code' => course1.provider.code.to_s,
      'Offers' => '1',
      'Unconditional firm' => '1',
    }
  end

  let(:ucas_match_for_apply_application) { create(:ucas_match, candidate: candidate2, matching_data: [dfe_matching_data, ucas_unwithdrawn_matching_data]) }
  let(:ucas_match_for_ucas_application) { create(:ucas_match, scheme: 'U', ucas_status: :offer, application_form: application_form1) }
  let(:ucas_match) { create(:ucas_match, scheme: 'B', ucas_status: :rejected, application_form: application_form3) }
  let(:ucas_matches) { [ucas_match_for_apply_application, ucas_match_for_ucas_application, ucas_match] }

  before do
    application_form2
    application_form4
  end

  it 'renders number of candidates on Apply' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[0].text).to include('4 candidates on Apply in this cycle')
  end

  it 'renders number of candidates matched with UCAS' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[1].text).to include('3 (75%) candidates matched with UCAS, of which')
  end

  it 'renders number of candidates that have accepted Apply offers and have unwithdrawn UCAS application' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[2].text).to include('1 (25% of candidates on Apply) have accepted Apply offers and have unwithdrawn UCAS application')
  end

  it 'renders number of candidates that have applied for the same course on both services' do
    result = render_inline(described_class.new(ucas_matches))

    expect(result.css('li')[3].text).to include('1 (25% of candidates on Apply) have applied for the same course on both services')
  end
end
