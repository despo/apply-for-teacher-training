module CandidateInterface
  module CourseChoices
    class ReplaceChoiceController < BaseController
      skip_before_action :redirect_to_dashboard_if_submitted
      before_action :render_404_if_flag_is_inactive

      def index
        redirect_to candidate_interface_replace_course_choice_show_path(
          current_application.course_choices_that_need_replacing.first.id
          ) and return if only_one_course_choice_needs_replacing?
      end

      def show
        @course_choice = current_application.application_choices.find(params['id'])
      end

    private

      def render_404_if_flag_is_inactive
        render_404 and return unless FeatureFlag.active?('replace_full_or_withdrawn_application_choices')
      end

      def only_one_course_choice_needs_replacing?
        current_application.course_choices_that_need_replacing&.count == 1
      end
    end
  end
end
