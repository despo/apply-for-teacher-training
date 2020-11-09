require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFeedbackComponent do
  before { FeatureFlag.activate(:feedback_prompts) }

  it 'renders successfully' do
    result = render_inline(
      described_class.new(
        section: 'references',
        path: 'candidate_interface_references_start_path',
        page_title: 'This is the references start page',
      ),
    )

    base_url = '/candidate/application/application-feedback'
    issues_query_string = '?issues=true&page_title=This+is+the+references+start+page&path=candidate_interface_references_start_path&section=references'
    no_issues_query_string = '?issues=false&page_title=This+is+the+references+start+page&path=candidate_interface_references_start_path&section=references'

    expect(result.css('a')[0].attributes['href'].value).to eq base_url + issues_query_string
    expect(result.css('a')[0].attributes['data-method'].value).to eq 'post'
    expect(result.css('a')[1].attributes['href'].value).to eq base_url + no_issues_query_string
    expect(result.css('a')[1].attributes['data-method'].value).to eq 'post'
  end
end
