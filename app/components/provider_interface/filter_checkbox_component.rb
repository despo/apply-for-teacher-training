module ProviderInterface
  class FilterCheckboxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :name, :text, :type

    def initialize(name:, text:, filter_options:, type:)
      @name = name
      @text = text
      @filter_options = filter_options
      @type = type
    end

    def should_be_checked
      @filter_options.include?(@name) ? 'checked' : nil
    end
  end
end
