class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    create_filter_query(application_choices, filters)
  end

  class << self
  private

    def search(application_choices, candidates_name)
      application_choices.where("CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{candidates_name}%")
    end

    def status(application_choices, filters)
      application_choices.where(status: filters[:status].keys)
    end

    def provider(application_choices, filters)
      application_choices.where('courses.provider_id' => filters[:provider].keys)
    end

    def accredited_provider(application_choices, filters)
      application_choices.where('courses.accredited_provider_id' => filters[:accredited_provider].keys)
    end

    def locations(application_choices, filters)
      application_choices.where('sites.id' => locations_ids_from_filters(filters))
    end

    def locations_ids_from_filters(filters)
      ids = []
      filters.keys.grep(/locations/).each do |location|
        ids << filters[location].keys
      end
      ids
    end

    def search_exists?(filters)
      filters.fetch(:search, {}).fetch(:candidates_name, '').empty? ? false : true
    end

    def create_filter_query(application_choices, filters)
      filtered_application_choices = application_choices
      filtered_application_choices = search(filtered_application_choices, filters[:search][:candidates_name]) if search_exists?(filters)
      filtered_application_choices = provider(filtered_application_choices, filters) if filters[:provider]
      filtered_application_choices = accredited_provider(filtered_application_choices, filters) if filters[:accredited_provider]
      filtered_application_choices = status(filtered_application_choices, filters) if filters[:status]
      filtered_application_choices = locations(application_choices, filters) if filters.keys.grep(/locations/).first
      filtered_application_choices
    end
  end
end
