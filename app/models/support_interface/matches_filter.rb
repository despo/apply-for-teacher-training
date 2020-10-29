module SupportInterface
  class MatchesFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filter_records(ucas_matches)
      if applied_filters[:year]
        ucas_matches = ucas_matches.where('recruitment_cycle_year IN (?)', applied_filters[:year])
      end

      ucas_matches
    end

    def filters
      [year_filter]
    end

  private

    def year_filter
      cycle_options = RecruitmentCycle::CYCLES.map do |year, label|
        {
          value: year,
          label: label,
          checked: applied_filters[:year]&.include?(year),
        }
      end

      {
        type: :checkboxes,
        heading: 'Recruitment cycle year',
        name: 'year',
        options: cycle_options,
      }
    end
  end
end
