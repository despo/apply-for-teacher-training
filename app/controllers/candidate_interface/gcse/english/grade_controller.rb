module CandidateInterface
  class Gcse::English::GradeController < CandidateInterfaceController
    include Gcse::GradeControllerConcern

    before_action :redirect_to_dashboard_if_submitted
    before_action :set_subject

    def edit
      @gcse_grade_form = english_gcse_grade_form
      @qualification_type = gcse_english_qualification.qualification_type

      render view_path
    end

    def update
      if multiple_gsces_are_active?
        english_gcses = params[:candidate_interface_english_gcse_grade_form][:english_gcses]
        @gcse_grade_form = english_gcse_grade_form.tap do |form|
          form.english = english_gcses.include? "english"
          form.grade_english = english_details_params[:grade_english]

          form.english_language = english_gcses.include? "english_language"
          form.grade_english_language = english_details_params[:grade_english_language]

          form.english_literature = english_gcses.include? "english_literature"
          form.grade_english_literature = english_details_params[:grade_english_literature]

          form.english_studies = english_gcses.include? "english_studies"
          form.grade_english_studies = english_details_params[:grade_english_studies]

          form.other_english_gcse = english_gcses.include? "other_english_gcse"
          form.other_english_gcse_name = english_details_params[:other_english_gcse_name]
          form.grade_other_english_gcse = english_details_params[:grade_other_english_gcse]
        end

      else
        @gcse_grade_form = english_gcse_grade_form
        @gcse_grade_form.grade = english_details_params[:grade]
        @gcse_grade_form.other_grade = english_details_params[:other_grade]
        @gcse_grade_form.save_grade
      end

      if @gcse_grade_form.save_grades
        update_gcse_completed(false)
        redirect_to next_gcse_path
      else
        track_validation_error(@gcse_grade_form)
        render view_path
      end
    end

  private

    def english_details_params
      params.require(:candidate_interface_english_gcse_grade_form).permit(%i[
            grade
            other_grade
            grade_english
            grade_english_language
            grade_english_literature
            grade_english_studies
            other_english_gcse_name
            grade_other_english_gcse])
    end

    def view_path
      if gcse_qualification? && multiple_gsces_are_active? && application_not_submitted_yet?
        'candidate_interface/gcse/english/grade/multiple_gcse_edit'
      else
        'candidate_interface/gcse/english/grade/edit'
      end
    end

    def gcse_qualification?
      gcse_english_qualification.qualification_type == 'gcse'
    end

    def multiple_gsces_are_active?
      FeatureFlag.active?('multiple_english_gcses')
    end

    def application_not_submitted_yet?
      @current_application.submitted_at.nil?
    end

    def gcse_english_qualification
      @gcse_english_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def english_gcse_grade_form
      @english_gcse_grade_form ||= EnglishGcseGradeForm.build_from_qualification(gcse_english_qualification)
    end

    def set_subject
      @subject = 'english'
    end
  end
end
