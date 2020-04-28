module VendorAPI
  class ApplicationsController < VendorAPIController
    def index
      application_choices = get_application_choices_for_provider_since(
        since: since_param,
      )

      render json: { data: MultipleApplicationsPresenter.new(application_choices).as_json }
    end

    def show
      application_choice = GetApplicationChoicesForProviders.call(providers: current_provider)
        .find(params[:application_id])

      render json: { data: SingleApplicationPresenter.new(application_choice).as_json }
    end

  private

    def get_application_choices_for_provider_since(since:)
      GetApplicationChoicesForProviders.call(providers: current_provider)
        .where('application_choices.updated_at > ?', since)
    end

    def since_param
      params.fetch(:since).to_datetime
    rescue ArgumentError
      raise ParameterInvalid.new('Parameter is invalid (should be ISO8601): since')
    end
  end
end
