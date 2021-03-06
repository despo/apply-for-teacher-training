module ProviderInterface
  class ChangeOfferComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :change_offer_form, :application_choice, :providers, :completion_url

    def initialize(change_offer_form:, providers:, completion_url:)
      @change_offer_form = change_offer_form
      @application_choice = change_offer_form.application_choice
      @providers = providers
      @completion_url = completion_url
      @change_offer_form.entry ||= change_offer_form.step # remember entry point
    end

    def sub_component
      step_to_render = if change_offer_form.valid?
                         change_offer_form.step
                       else
                         change_offer_form.previous_step
                       end

      case step_to_render
      when :confirm
        ProviderInterface::ChangeOffer::ConfirmComponent.new(
          change_offer_form: change_offer_form,
          completion_url: completion_url,
        )
      when :course_option
        ProviderInterface::ChangeOffer::ChangeLocationComponent.new(
          change_offer_form: change_offer_form,
        )
      when :study_mode
        study_modes = Course.find(change_offer_form.course_id).available_study_modes_from_options
        if study_modes.count > 1
          ProviderInterface::ChangeOffer::ChangeStudyModeComponent.new(
            change_offer_form: change_offer_form,
          )
        else # skip to next step
          change_offer_form.study_mode = study_modes.first
          change_offer_form.step = change_offer_form.next_step
          sub_component
        end
      when :course
        ProviderInterface::ChangeOffer::ChangeCourseComponent.new(
          change_offer_form: change_offer_form,
        )
      when :provider
        ProviderInterface::ChangeOffer::ChangeProviderComponent.new(
          change_offer_form: change_offer_form,
          providers: providers,
        )
      end
    end
  end
end
