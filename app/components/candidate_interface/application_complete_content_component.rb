module CandidateInterface
  class ApplicationCompleteContentComponent < ViewComponent::Base
    include ViewHelper

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
      @dates = ApplicationDates.new(@application_form)
    end

    delegate :any_accepted_offer?,
             :all_provider_decisions_made?,
             :any_awaiting_provider_decision?,
             :all_choices_withdrawn?,
             :any_recruited?,
             :any_offers?,
             :all_applications_not_sent?, to: :application_form

    def editable?
      @dates.form_open_to_editing?
    end

    def decline_by_default_remaining_days
      distance_in_days = (@dates.decline_by_default_at.to_date - Date.current).to_i

      [0, distance_in_days].max
    end

    def decline_by_default_date
      @dates.decline_by_default_at.to_s(:govuk_date)
    end

    def choice_count
      application_form.application_choices.size
    end

    def heading
      if any_recruited?
        I18n.t!('application_complete.headings.recruited')
      elsif any_accepted_offer?
        I18n.t!('application_complete.headings.accepted_offer')
      elsif all_choices_withdrawn?
        I18n.t!('application_complete.headings.all_withdrawn')
      elsif all_applications_not_sent?
        "#{'Course'.pluralize(choice_count)} you’ve applied to"
      elsif all_provider_decisions_made?
        I18n.t!('application_complete.headings.all_provider_decisions_made', count: choice_count)
      elsif any_offers?
        I18n.t!('application_complete.headings.some_provider_decisions_made')
      else
        "#{'Course'.pluralize(choice_count)} you’ve applied to"
      end
    end

  private

    attr_reader :application_form
  end
end
