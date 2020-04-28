module CandidateInterface
  class TrainingWithADisabilityController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def edit
      @training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(
        current_application,
      )
    end

    def update
      @training_with_a_disability_form = TrainingWithADisabilityForm.new(training_with_a_disability_params)

      if @training_with_a_disability_form.save(current_application)
        @application_form = current_application
        redirect_to candidate_interface_training_with_a_disability_show_path
      else
        track_validation_error(@training_with_a_disability_form)
        render :edit
      end
    end

    def show
      @application_form = current_application
      @training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(
        current_application,
      )
    end

  private

    def training_with_a_disability_params
      params.require(:candidate_interface_training_with_a_disability_form).permit(
        :disclose_disability, :disability_disclosure
      )
    end
  end
end
