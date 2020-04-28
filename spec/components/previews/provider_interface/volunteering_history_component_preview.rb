module ProviderInterface
  class VolunteeringHistoryComponentPreview < ViewComponent::Preview
    def application
      render_component_for application_form: application_form
    end

  private

    def application_form
      @application_form ||= ApplicationForm.joins(
        :application_volunteering_experiences,
      ).limit(25).sample
    end

    def render_component_for(application_form:)
      if !application_form.application_work_experiences.empty?
        render ProviderInterface::VolunteeringHistoryComponent.new(application_form: application_form)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end
