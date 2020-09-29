module SupportInterface
  class UCASMatchesStatisticsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(ucas_matches)
      @ucas_matches = ucas_matches
    end

    def candidates_on_apply_count
      @candidates_on_apply_count ||= ApplicationChoice.where(status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER)
        .includes([:application_form]).map(&:application_form).map(&:candidate_id).uniq.compact.size
    end

    def candidates_matched_with_ucas_count
      count = @ucas_matches.size

      "#{count} (#{formated_percentage(count, candidates_on_apply_count)})"
    end

    def accepted_on_apply_unwithdrawn_from_ucas
      candidate_ids = []
      @ucas_matches.map do |match|
        accepted_on_apply = []
        unwithdrawn_from_ucas = []
        ucas_matched_applications(match).each do |matched_application|
          accepted_on_apply << true if matched_application.accepted_on_apply?
          unwithdrawn_from_ucas << true if matched_application.unwithdrawn_from_ucas?
          break if accepted_on_apply.any? && unwithdrawn_from_ucas.any?
        end

        candidate_ids << match.candidate.id if accepted_on_apply.any? && unwithdrawn_from_ucas.any?
      end
      count = candidate_ids.uniq.compact.count

      "#{count} (#{formated_percentage(count, candidates_on_apply_count)} of candidates on Apply)"
    end

    def applied_for_the_same_course_on_both_services
      candidate_ids = @ucas_matches.map(&:matching_data).flatten.map do |data|
        data['Apply candidate ID'] if data['Scheme'] == 'B'
      end
      count = candidate_ids.uniq.compact.count

      "#{count} (#{formated_percentage(count, candidates_on_apply_count)} of candidates on Apply)"
    end

  private

    def ucas_matched_applications(match)
      match.matching_data.map do |data|
        UCASMatchedApplication.new(data, match.created_at.year)
      end
    end

    def formated_percentage(count, total)
      percentage = count.percent_of(total)
      precision = (percentage % 1).zero? ? 0 : 2
      number_to_percentage(count.percent_of(total), precision: precision)
    end
  end
end

class Numeric
  def percent_of(number)
    to_f / number * 100.0
  end
end
