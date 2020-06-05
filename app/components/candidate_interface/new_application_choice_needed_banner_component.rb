module CandidateInterface
  class NewApplicationChoiceNeededBannerComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      a_course_has_been_withdrawn || an_application_choice_has_become_full
    end

  private

    def a_course_has_been_withdrawn
      binding.pry
      application_form.application_choices.map(&:application_form).map(&:withdrawn).any?
    end

    attr_reader :application_form
  end
end
