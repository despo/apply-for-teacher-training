module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class DecisionController < BaseController
        def choose_action
          @course_choice = current_application.application_choices.find(params['id'])
        end

        def route_action
          @pick_replacement_action = PickReplacementActionForm.new(replacement_action_params)
          @course_choice = current_application.application_choices.find(params['id'])

          if @pick_replacement_action.replacement_action == 'replace_location'
            redirect_to candidate_interface_replace_course_choice_update_location_path(@course_choice.id)
          elsif @pick_replacement_action.replacement_action == 'replace_study_mode'
            replacement_course_option_id = @course_choice.course_option.get_alternative_study_mode.id

            redirect_to candidate_interface_confirm_replacement_course_choice_path(@course_choice.id, replacement_course_option_id)
          elsif @pick_replacement_action.replacement_action == 'keep_choice'
            if only_one_course_choice_needs_replacing?
              redirect_to candidate_interface_application_complete_path
            else
              redirect_to candidate_interface_replace_course_choices_path
            end
          elsif @pick_replacement_action.replacement_action == 'remove_course'
            redirect_to candidate_interface_confirm_cancel_full_course_choice_path
          elsif @pick_replacement_action.replacement_action == 'replace_course'
            redirect_to candidate_interface_replace_course_choices_choose_path(@course_choice.id)
          elsif !@pick_replacement_action.valid?
            flash[:warning] = 'Please select an option to update your course choice.'

            redirect_to candidate_interface_replace_course_choice_path(@course_choice.id)
          else
            render :contact_support
          end
        end

        def contact_support
          @course_choice = current_application.application_choices.find(params['id'])
        end

      private

        def replacement_action_params
          return nil unless params.key?(:candidate_interface_pick_replacement_action_form)

          params.require(:candidate_interface_pick_replacement_action_form).permit(:replacement_action)
        end
      end
    end
  end
end
