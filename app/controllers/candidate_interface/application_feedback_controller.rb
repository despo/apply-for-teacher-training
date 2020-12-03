module CandidateInterface
  class ApplicationFeedbackController < CandidateInterfaceController
    def new
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(
        path: params[:path],
        page_title: params[:page_title],
        original_controller: params[:original_controller],
      )
    end

    def create
      @application_feedback_form = CandidateInterface::ApplicationFeedbackForm.new(feedback_params)

      if @application_feedback_form.save(current_application)
        redirect_to candidate_interface_application_feedback_thank_you_path
      else
        @application_feedback_form.set_booleans
        track_validation_error(@references_relationship_form)

        render :new
      end
    end

    def thank_you; end

  private

    def feedback_params
      params.require(:candidate_interface_application_feedback_form).permit(
        :path, :page_title, :does_not_understand_section,
        :need_more_information, :answer_does_not_fit_format,
        :other_feedback, :consent_to_be_contacted,
        :original_controller
      )
    end
  end
end