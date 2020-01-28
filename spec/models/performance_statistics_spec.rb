require 'rails_helper'

RSpec.describe PerformanceStatistics, type: :model do
  it 'excludes candidates marked as hidden from reporting' do
    hidden_candidate = create(:candidate, hide_in_reporting: true)
    visible_candidate = create(:candidate, hide_in_reporting: false)
    create(:application_form, candidate: hidden_candidate)
    create(:application_form, candidate: visible_candidate)

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(1)
    expect(stats.application_form_counts_total).to eq(1)
  end

  it 'breaks down candidates with unsubmitted forms into stages' do
    create(:candidate)
    create_list(:application_form, 2)
    create_list(:application_form, 3, updated_at: 3.minutes.from_now) # changed forms
    create_list(:completed_application_form, 4, updated_at: 3.minutes.from_now)

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(10)
    expect(stats[:candidates_signed_up_but_not_signed_in]).to eq(1)
    expect(stats[:candidates_signed_in_but_not_entered_data]).to eq(2)
    expect(stats[:candidates_with_unsubmitted_forms]).to eq(3)
    expect(stats[:candidates_with_submitted_forms]).to eq(4)
  end

  it 'avoids double counting generated test data' do
    form = create(:completed_application_form)
    form.update_column(:updated_at, form.created_at) # this form is both unchanged but also submitted

    stats = PerformanceStatistics.new

    expect(stats[:total_candidate_count]).to eq(1)
    expect(stats[:candidates_with_submitted_forms]).to eq(1)
    expect(stats[:candidates_signed_in_but_not_entered_data]).to eq(0)
  end

  it 'classifies application forms in the same way as ProcessState' do
    create(:course_option, course: create(:course, open_on_apply: true))
    create(:course_option, course: create(:course, open_on_apply: true))

    TestApplications.create_application states: [:unsubmitted]
    TestApplications.create_application states: [:awaiting_references]
    TestApplications.create_application states: [:application_complete]
    TestApplications.create_application states: [:awaiting_provider_decision]
    TestApplications.create_application states: %i[offer offer]
    TestApplications.create_application states: %i[offer rejected]
    TestApplications.create_application states: %i[rejected rejected]
    TestApplications.create_application states: [:declined]
    TestApplications.create_application states: [:accepted]
    TestApplications.create_application states: [:recruited]
    TestApplications.create_application states: [:enrolled]
    TestApplications.create_application states: [:withdrawn]

    stats = PerformanceStatistics.new.application_form_status_counts.inject({}) do |agg, row|
      agg[row['status']] = row['count']
      agg
    end

    process_state_counts = ApplicationForm.all.inject(Hash.new(0)) do |total, form|
      state = ProcessState.new(form).state.to_s
      total[state] += 1
      total
    end

    expect(stats).to eq(process_state_counts)
  end
end
