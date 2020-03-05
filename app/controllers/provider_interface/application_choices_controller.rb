module ProviderInterface
  class ApplicationChoicesController < ProviderInterfaceController
    def index
      @sort_order = params[:sort_order].eql?('asc') ? 'asc' : 'desc'
      @sort_by = params[:sort_by].presence || 'last-updated'

      application_choices = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .order(ordering_arguments(@sort_by, @sort_order))

      application_choices = application_choices.page(params[:page] || 1) if FeatureFlag.active?('provider_interface_pagination')

      if FeatureFlag.active?('provider_application_filters')
        raise 'feature not implemented yet'
      else
        @application_choices = application_choices
      end

      respond_to do |format|
        format.html
        format.csv do
          send_data(
            ApplicationChoicesCsvPresenter.new(@application_choices).present,
            filename: ApplicationChoicesCsvPresenter.filename,
          )
        end
      end
    end

    def show
      @application_choice = GetApplicationChoicesForProviders.call(providers: current_provider_user.providers)
        .find(params[:application_choice_id])
    end

  private

    def ordering_arguments(sort_by, sort_order)
      {
        'course' => { 'courses.name' => sort_order },
        'last-updated' => { 'application_choices.updated_at' => sort_order },
        'name' => { 'last_name' => sort_order, 'first_name' => sort_order },
      }[sort_by]
    end
  end
end
