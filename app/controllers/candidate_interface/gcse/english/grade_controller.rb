module CandidateInterface
  class Gcse::English::GradeController < CandidateInterfaceController
    include Gcse::GradeControllerConcern

    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @application_qualification = details_form
      @qualification_type = details_form.qualification.qualification_type

      if FeatureFlag.active?('multiple_english_gcses') && @current_application.submitted_at.nil?
        render 'candidate_interface/gcse/english/grade/multiple_gcse_edit' and return
      else
        render :edit
      end
    end

    def update
      @qualification_type = details_form.qualification.qualification_type

      details_form.grade = details_params[:grade]
      details_form.other_grade = details_params[:other_grade]

      @application_qualification = details_form.save_grade

      if @application_qualification
        update_gcse_completed(false)
        redirect_to next_gcse_path
      else
        @application_qualification = details_form
        track_validation_error(@application_qualification)

        render :edit
      end
    end

  private

    def set_subject
      @subject = 'english'
    end
  end
end
