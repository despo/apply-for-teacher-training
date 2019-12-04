module SupportInterface
  class ApplicationFormsController < SupportInterfaceController
    def index
      @application_forms = ApplicationForm.includes(:application_choices).sort_by(&:updated_at).reverse
    end

    def show
      @application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])
    end

    def audit
      @application_form = ApplicationForm
        .includes(:application_choices)
        .find(params[:application_form_id])
    end

    def create_test_applications
      flash[:success] = "Scheduled a job to create new applications!"
      AddTestApplicationsWorker.perform_async
      redirect_to action: 'index'
    end
  end
end
