module ProviderInterface
  class ClearFilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :current_sort_by, :css_class, :filter_visible, :sort_order

    def initialize(page_state:)
      @current_sort_by = page_state.sort_by
      @sort_order = page_state.sort_order
      @filter_visible = page_state.filter_visible
    end

  end
end
