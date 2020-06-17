module CandidateInterface
  module CourseChoices
    module ReplaceChoices
      class CourseSelectionController < BaseController
        def new
            @pick_course = PickCourseForm.new(
              provider_id: params.fetch(:provider_id),
              application_form: current_application,
            )
        end

        def create
          @course_choice = current_application.application_choices.find(params['id'])
          course_id = params.dig(:candidate_interface_pick_course_form, :course_id)
          @pick_course = PickCourseForm.new(
            provider_id: params.fetch(:provider_id),
            course_id: course_id,
            application_form: current_application,
          )
          render :new and return unless @pick_course.valid?

          if !@pick_course.open_on_apply?
            redirect_to candidate_interface_replace_course_choices_ucas_with_course_path(@course_choice.id, @pick_course.provider_id, @pick_course.course_id)
          elsif @pick_course.full?
            redirect_to candidate_interface_course_choices_full_path(
              @pick_course.provider_id,
              @pick_course.course_id,
            )
          elsif @pick_course.both_study_modes_available?
            redirect_to candidate_interface_course_choices_study_mode_path(
              @pick_course.provider_id,
              @pick_course.course_id,
              course_choice_id: params[:course_choice_id],
            )
          elsif @pick_course.single_site?
            course_option = CourseOption.where(course_id: @pick_course.course.id).first
            PickCourseOption.new(
              course_id,
              course_option.id,
              current_application,
              params.fetch(:provider_id),
              self,
            ).call
          else
            redirect_to candidate_interface_course_choices_site_path(
              @pick_course.provider_id,
              @pick_course.course_id,
              @pick_course.study_mode,
              course_choice_id: params[:course_choice_id],
            )
          end
        end

        def full
          @course = Course.find(params[:course_id])
        end
      end
    end
  end
end
