module CandidateInterface
  module CourseChoices
    class ReplaceChoiceController < BaseController
      skip_before_action :redirect_to_dashboard_if_submitted
      before_action :render_404_if_flag_is_inactive

      def index
        if only_one_course_choice_needs_replacing?
          redirect_to candidate_interface_replace_course_choice_decision_path(
            current_application.course_choices_that_need_replacing.first.id,
          ) and return
        end
      end

      def decision
        @replacement_decision_form = ReplacementDecisionForm.new
        @course_choice = current_application.application_choices.find(params['id'])
        @pluralize_provider = 'provider'.pluralize(provider_count)
        @course_name_and_code = @course_choice.provider.name_and_code
        @provider_name = @course_choice.provider.name
        @full_or_withdrawn = @course_choice.course.withdrawn ? 'not running anymore' : 'now full'
      end

      def record_decision
        @replacement_decision_form = ReplacementDecisionForm.new(decision_params)
      end

    private

      def render_404_if_flag_is_inactive
        render_404 and return unless FeatureFlag.active?('replace_full_or_withdrawn_application_choices')
      end

      def only_one_course_choice_needs_replacing?
        current_application.course_choices_that_need_replacing&.count == 1
      end

      def provider_count
        current_application.application_choices.map(&:provider).uniq.count
      end

      def decision_params
        params.fetch(:candidate_interface_replacement_decision_form, {}).permit(:decision)
      end
    end
  end
end
