module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class StudyModeSelectionController < BaseController
        def new
          @course_choice = current_application.application_choices.find(params['id'])
          @pick_study_mode = PickStudyModeForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: params.fetch(:course_id),
          )
        end

        def create
          @course_choice = current_application.application_choices.find(params['id'])
          @pick_study_mode = PickStudyModeForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: params.fetch(:course_id),
            study_mode: params.dig(
              :candidate_interface_pick_study_mode_form,
              :study_mode,
            ),
          )
          render :new and return unless @pick_study_mode.valid?

          if @pick_study_mode.single_site_course?
            PickCourseOption.new(
              @pick_study_mode.course_id,
              @pick_study_mode.first_site_id,
              current_application,
              params.fetch(:provider_id),
              self,
            ).call
          else
            redirect_to candidate_interface_replace_course_choice_location_path(
              @course_choice.id,
              @pick_study_mode.provider_id,
              @pick_study_mode.course_id,
              @pick_study_mode.study_mode,
            )
          end
        end
      end
    end
  end
end
