module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class SiteSelectionController < BaseController
        def new
          @pick_site = PickSiteForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: params.fetch(:course_id),
            study_mode: params.fetch(:study_mode),
          )
        end

        def update
          @course_choice = current_application.application_choices.find(params['id'])
          @pick_site = create_pick_site_form(@course_choice, @course_choice.course_option.id)
          @study_mode = params['study_mode']
        end

        def validate_location
          @course_choice = current_application.application_choices.find(params['id'])
          @replacement_course_option_id = params.dig('candidate_interface_pick_site_form', 'course_option_id')
          @pick_site = create_pick_site_form(@course_choice, @replacement_course_option_id)

          if @pick_site.valid?
            redirect_to candidate_interface_confirm_replacement_course_choice_path(@course_choice.id, @replacement_course_option_id)
          else
            flash[:warning] = 'Please select a new location.'
            redirect_to candidate_interface_replace_course_choice_update_location_path(@course_choice.id)
          end
        end
      end
    end
  end
end
