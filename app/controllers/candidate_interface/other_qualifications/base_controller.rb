module CandidateInterface
  class OtherQualifications::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      qualifications = OtherQualificationForm.build_all_from_application(current_application)

      @qualification = if qualifications.any?
                         OtherQualificationForm.new(
                           qualification_type: qualifications.last.qualification_type,
                           institution_name: qualifications.last.institution_name,
                           award_year: qualifications.last.award_year,
                         )
                       else
                         OtherQualificationForm.new
                       end
    end

    def create
      @qualification = OtherQualificationForm.new(other_qualification_params)

      if @qualification.save
        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification)
        render :new
      end
    end

    def edit
      current_qualification = current_application.application_qualifications.other.find(current_other_qualification_id)
      @qualification = OtherQualificationForm.build_from_qualification(current_qualification)
    end

    def update
      @qualification = OtherQualificationForm.new(other_qualifcations_update_params)

      if @qualification.update(current_application)
        current_application.update!(other_qualifications_completed: false)

        redirect_to candidate_interface_review_other_qualifications_path
      else
        track_validation_error(@qualification)
        render :edit
      end
    end

  private

    def current_other_qualification_id
      params.permit(:id)[:id]
    end

    def other_qualification_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :id, :qualification_type, :subject, :institution_name, :grade, :award_year
      )
        .transform_values(&:strip)
    end

    def other_qualifcations_update_params
      params.require(:candidate_interface_other_qualification_form).permit(
        :qualification_type, :subject, :institution_name, :grade, :award_year
      ).merge!(id: params[:id])
        .transform_values(&:strip)
    end
  end
end
