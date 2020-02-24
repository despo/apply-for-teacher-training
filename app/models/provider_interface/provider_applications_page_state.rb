module ProviderInterface
  class ProviderApplicationsPageState
    attr_reader :sort_order, :sort_by, :filter_visible, :provider_filter_options, :status_filter_options

    def initialize(params:)
      @params = params
      @sort_order = params[:sort_order].eql?('asc') ? 'asc' : 'desc'
      @sort_by = params[:sort_by].presence || 'last-updated'
      @filter_visible = params['filter_visible'] ||= 'true'
      @status_filter_options = extract_status_filter_options
      @provider_filter_options = extract_provider_filter_options
    end

    def ordering_arguments
      {
        'course' => { 'courses.name' => sort_order },
        'last-updated' => { 'application_choices.updated_at' => sort_order },
        'name' => { 'last_name' => sort_order, 'first_name' => sort_order },
      }[@sort_by]
    end

  private

    def extract_status_filter_options
      @params.fetch('filter', {}).fetch('status',false) ? @params['filter']['status'].keys : []
    end

    def extract_provider_filter_options
      @params.fetch('filter', {}).fetch('provider',false) ? @params['filter']['provider'].keys : []
    end
  end
end
