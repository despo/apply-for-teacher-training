module ProviderInterface
  class SortableColumnHeadingComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :column_name, :current_sort_by, :css_class, :params_for_current_state

    def initialize(sort_order:, column_name:, current_sort_by:, css_class:, params_for_current_state:)
      @sort_order = sort_order
      @column_name = column_name
      @current_sort_by = current_sort_by
      @css_class = css_class
      @params_for_current_state = params_for_current_state
    end

    def default_sort_order
      'desc'
    end

    def toggle_sort_order
      @sort_order.to_sym == :desc ? :asc : :desc
    end

    def aria_sort_order
      @sort_order.to_sym == :desc ? 'descending' : 'ascending'
    end

    def sort_by
      column_name.parameterize
    end

    def should_have_sort?
      sort_by.eql?(current_sort_by)
    end
  end
end
