module ProviderInterface
  class ProviderApplicationsPageState
    attr_accessor :sort_order, :sort_by, :available_filters, :filter_visible, :filter_selections, :provider_user

    def initialize(params:, provider_user:)
      @params = params
      @provider_user = provider_user
      @sort_order = calculate_sort_order
      @sort_by = calculate_sort_by
      @available_filters = calculate_available_filters
      @filter_visible =  calculate_filter_visibility
      @filter_selections = calculate_filter_selections
      @locations = provider_locations_filters_builder
    end

    def applications_ordering_query
      {
        'course' => { 'courses.name' => @sort_order },
        'last-updated' => { 'application_choices.updated_at' => @sort_order },
        'name' => { 'last_name' => @sort_order, 'first_name' => @sort_order },
      }[@sort_by]
    end

    def to_h
      {
        sort_order: @sort_order,
        sort_by: @sort_by,
        filter_visible: @filter_visible,
        filter_selections: @filter_selections,
      }
    end

  private

    def calculate_filter_visibility
      filter_params[:filter_visible] ||= 'true'
    end

    def calculate_filter_selections
      filter_selections = filter_params[:filter_selections].to_h ||= {}
      remove_candiates_name_search_if_empty(filter_selections)
    end

    def remove_candiates_name_search_if_empty(filter_selections)
      return filter_selections if filter_selections.empty?

      filter_selections.delete(:search) if filter_selections.dig(:search, :candidates_name) == ''
      filter_selections
    end

    def locations_keys
      locations_keys_hash = {}
      if @params[:filter_selections]
        @params[:filter_selections].keys.grep(/locations/).each do |location|
          locations_keys_hash[location.to_sym] = {}
        end
      end
      locations_keys_hash
    end

    def filter_params
      @params.permit(:filter_visible,
                     filter_selections: { search: {},
                                          status: {},
                                          provider: {},
                                          accredited_provider: {},}.merge(locations_keys))
    end

    def calculate_sort_order
      @params[:sort_order].eql?('asc') ? 'asc' : 'desc'
    end

    def calculate_sort_by
      @params[:sort_by].presence || 'last-updated'
    end

    def providers_have_been_selected?
      calculate_filter_selections[:provider].present?
    end

    def provider_ids_from_selections
      calculate_filter_selections[:provider].keys
    end

    def providers_with_sites(ids:)
      Provider.includes([:sites]).where(id: ids)
    end

    def sites_config(provider:)
      provider.sites.map do |site|
        {
          type: 'checkbox',
          text: site.name,
          name: site.id.to_s,
        }
      end
    end

    def providers_locations_config
      providers_with_sites(ids: provider_ids_from_selections).map do |provider|
        {
          heading: "Locations for #{provider.name}",
          group_type: 'location',
          input_config: sites_config(provider: provider),
        }
      end
    end

    def calculate_available_filters
     (search_filters << status_filters << provider_filters_builder << accredited_provider_filters_builder) + provider_locations_filters_builder
    end

    def search_filters
      [
        {
          heading: 'candidate\'s name',
          input_config: [{
            type: 'search',
            text: '',
            name: 'candidates_name',
          }],
        },
      ]
    end

    def status_filters
      status_options = %w[
        awaiting_provider_decision
        offer
        pending_conditions
        recruited
        enrolled
        rejected
        declined
        withdrawn
        conditions_not_met
        offer_withdrawn
      ].map do |state_name|
        {
          type: 'checkbox',
          text: I18n.t!("provider_application_states.#{state_name}"),
          name: state_name,
        }
      end

      {
        heading: 'status',
        input_config: status_options,
      }
    end

    def provider_filters_builder
      input_config = ProviderOptionsService.new(provider_user).providers.map do |provider|
        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      {
        heading: 'provider',
        input_config: input_config,
      }
    end

    def accredited_provider_filters_builder
      input_config = ProviderOptionsService.new(provider_user).accredited_providers.map do |provider|
        {
          type: 'checkbox',
          text: provider.name,
          name: provider.id.to_s,
        }
      end

      {
        heading: 'accredited_provider',
        input_config: input_config,
      }
    end

    def provider_locations_filters_builder
      return providers_locations_config if providers_have_been_selected?
      []
    end
  end
end
