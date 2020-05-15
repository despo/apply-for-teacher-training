module ProviderInterface
  class FilterCheckboxComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :name, :text, :selected, :heading, :full_text

    def initialize(name:, text:, selected:, heading:, full_text:)
      @name = name
      @text = text
      @full_text = full_text
      @selected = selected
      @heading = heading
    end
  end
end
