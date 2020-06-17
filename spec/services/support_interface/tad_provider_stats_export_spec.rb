require 'rails_helper'

RSpec.describe SupportInterface::TADProviderStatsExport do
  include CourseOptionHelpers

  subject(:exported_rows) { SupportInterface::TADProviderStatsExport.new.call }

  describe 'calculating offers and acceptances' do
    test_data = [
      [%i[awaiting_provider_decision offer recruited enrolled], 4, 3, 2],
      [%i[recruited enrolled], 2, 2, 2],
      [[], 0, 0, 0],
      [%i[withdrawn rejected], 2, 0, 0],
      [ApplicationStateChange::STATES_NOT_VISIBLE_TO_PROVIDER, 0, 0, 0],
    ]

    test_data.each do |states, applications, offers, acceptances|
      it "correctly reports overall/offered/accepted tallies for applications in the state #{states}" do
        provider = create(:provider)
        course_option = course_option_for_provider(provider: provider)
        generator = TestApplications.new

        states.each do |state|
          generator.create_application(states: [state], courses_to_apply_to: [course_option.course])
        end

        expect(exported_rows.first[:applications]).to eq applications
        expect(exported_rows.first[:offers]).to eq offers
        expect(exported_rows.first[:acceptances]).to eq acceptances
      end
    end

    it 'correctly reports course metadata' do
      provider_one = create(:provider, code: 'ABC1', name: 'Tehanu')
      provider_two = create(:provider, code: 'DEF2', name: 'Anarres')

      course_option_for_provider(provider: provider_one, course: create(:course, :open_on_apply, name: 'History', provider: provider_one))
      course_option_for_provider(provider: provider_one, course: create(:course, :open_on_apply, name: 'Biology', provider: provider_one))
      course_option_for_provider(provider: provider_two, course: create(:course, :open_on_apply, name: 'Science book', provider: provider_two))
      course_option_for_provider(provider: provider_two, course: create(:course, :open_on_apply, name: 'French I took', provider: provider_two))

      # we get a row per course
      expect(exported_rows.count).to eq(4)

      # rows are correctly divided between providers
      expect(exported_rows.map { |r| r[:provider] }.tally['Tehanu']).to eq(2)
      expect(exported_rows.map { |r| r[:provider] }.tally['Anarres']).to eq(2)

      # rows contain metadata
      example_row = exported_rows.find { |r| r[:subject] == 'History' }
      expect(example_row[:provider]).to eq('Tehanu')
      expect(example_row[:provider_code]).to eq('ABC1')
    end
  end
end