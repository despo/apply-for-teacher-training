require 'rails_helper'

RSpec.describe PerformanceStatistics, type: :model do
  describe '#application_form_status_counts' do
    it 'counts unsubmitted applications' do
      application_choice = create(:application_choice, status: 'unsubmitted')

      expect(ProcessState.new(application_choice.application_form).state).to eql :unsubmitted

      expect(count_for_process_state(:unsubmitted)).to eql(1)
    end

    it 'counts awaiting references applications' do
      application_choice = create(:application_choice, status: 'awaiting_references')

      expect(ProcessState.new(application_choice.application_form).state).to eql :awaiting_references

      expect(count_for_process_state(:awaiting_references)).to eql(1)
    end

    # etc etc
  end

  def count_for_process_state(process_state)
    PerformanceStatistics.new.application_form_status_counts.find { |x| x['status'] == process_state.to_s }['count']
  end

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
end
