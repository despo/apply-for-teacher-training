module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, only: %i[show review]
    before_action :redirect_to_application_form_unless_submitted, only: %i[review_submitted complete submit_success]

    def show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_form = current_application
      @previous_application_form = ApplicationForm.find(current_application.previous_application_form_id) if current_application.previous_application_form_id.present?
    end

    def before_you_start; end

    def start_apply_again
      render_404 and return unless FeatureFlag.active?('apply_again')
    end

    def apply_again
      render_404 and return unless FeatureFlag.active?('apply_again')

      DuplicateApplication.new(current_application).duplicate
      flash[:success] = 'Your new application is ready for editing'
      redirect_to candidate_interface_application_form_path
    end

    def review
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
      @application_form = current_application
    end

    def edit
      redirect_to candidate_interface_application_complete_path and return unless current_application.apply_1?

      @editable_days = TimeLimitConfig.edit_by
      render :edit_by_support
    end

    def complete
      @application_form = current_application
    end

    def submit_show
      @application_form = current_application
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if @application_form_presenter.ready_to_submit?
        @further_information_form = FurtherInformationForm.new
      else
        @errors = @application_form_presenter.section_errors
        @application_choice_errors = @application_form_presenter.application_choice_errors

        render :review
      end
    end

    def submit
      @further_information_form = FurtherInformationForm.new(further_information_params)

      if @further_information_form.save(current_application)
        SubmitApplication.new(current_application).call

        if current_application.apply_again?
          SendApplyAgainApplicationToProvider.call(application_form: current_application)
        end

        redirect_to candidate_interface_application_submit_success_path
      else
        track_validation_error(@further_information_form)
        render :submit_show
      end
    end

    def submit_success
      @application_form = current_application
      @support_reference = current_application.support_reference
      @editable_days = TimeLimitConfig.edit_by
      provider_count = current_application.unique_provider_list.size
      @pluralized_provider_string = 'provider'.pluralize(provider_count)
    end

    def review_submitted
      @application_form = current_application
    end

    def review_previous_application
      @application_form = current_candidate.application_forms.find(params[:id])
      @review_previous_application = true

      render :review_submitted
    rescue ActiveRecord::RecordNotFound
      render_404
    end

  private

    def further_information_params
      params.require(:candidate_interface_further_information_form).permit(
        :further_information,
        :further_information_details,
      )
        .transform_values(&:strip)
    end
  end
end
