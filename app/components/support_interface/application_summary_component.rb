module SupportInterface
  class ApplicationSummaryComponent < ViewComponent::Base
    include ViewHelper

    delegate :support_reference,
             :submitted_at,
             :submitted?,
             :updated_at,
             :edit_by,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        support_reference_row,
        submitted_row,
        edit_by_row,
        last_updated_row,
        state_row,
        ucas_match_row,
        previous_application_row,
        subsequent_application_row,
      ].compact
    end

  private

    def last_updated_row
      {
        key: 'Last updated',
        value: "#{updated_at.to_s(:govuk_date_and_time)} (#{govuk_link_to('See history', support_interface_application_form_audit_path(application_form))}, #{govuk_link_to('Emails about application', support_interface_email_log_path(application_form_id: application_form.id))})".html_safe,
      }
    end

    def submitted_row
      if submitted?
        {
          key: 'Submitted',
          value: submitted_at.to_s(:govuk_date_and_time),
        }
      end
    end

    def edit_by_row
      if edit_by
        {
          key: 'Edit by',
          value: edit_by.to_s(:govuk_date_and_time).to_s,
        }
      end
    end

    def support_reference_row
      if support_reference
        {
          key: 'Support reference',
          value: support_reference,
        }
      end
    end

    def state_row
      {
        key: 'State',
        value: formatted_status,
      }
    end

    def ucas_match_row
      value = if ucas_match
                govuk_link_to('View matching data', support_interface_ucas_match_path(ucas_match))
              else
                'No matching data'
              end

      {
        key: 'UCAS matching data for this candidate',
        value: value,
      }
    end

    def previous_application_row
      return unless application_form.previous_application_form

      {
        key: 'Previous application',
        value: govuk_link_to(application_form.previous_application_form.support_reference, support_interface_application_form_path(application_form.previous_application_form)),
      }
    end

    def subsequent_application_row
      return unless application_form.subsequent_application_form

      {
        key: 'Subsequent application',
        value: govuk_link_to(application_form.subsequent_application_form.support_reference, support_interface_application_form_path(application_form.subsequent_application_form)),
      }
    end

    def formatted_status
      process_state = ProcessState.new(application_form).state
      name = I18n.t!("candidate_flow_application_states.#{process_state}.name")
      desc = I18n.t!("candidate_flow_application_states.#{process_state}.description")
      "#{name} – #{desc}"
    end

    def ucas_match
      application_form.candidate.ucas_match
    end

    attr_reader :application_form
  end
end
