module SupportInterface
  class UCASMatchActionComponent < ViewComponent::Base
    include ViewHelper

    # ACTIONS = {
    #   send_initial_emails: {
    #     text: 'Confirm initial emails were sent',
    #     form_path: support_interface_record_initial_emails_sent_path(@match),
    #   },
    #   send_reminder_emails: {
    #     text: 'Confirm reminder emails were sent',
    #     form_path: support_interface_record_reminder_emails_sent_path(@match),
    #   },
    #   request_withdrawal_from_ucas: {
    #     text: 'Confirm initial emails were sent',
    #     form_path: support_interface_record_withdrawal_from_ucas_path(@match),
    #   },
    #   confirm_withdrawal_from_ucas: {
    #     text: 'Confirm the application was withdrawn from UCAS',
    #     form_path: support_interface_processed_path(@match),
    #   }
    # }.freeze

    def initialize(match)
      @match = match
    end

    def inset_text_header
      puts @match.dual_application_or_dual_acceptance?
      puts @match.action_needed?
      return 'No action required' if !@match.dual_application_or_dual_acceptance? || !@match.action_needed?

      type_of_action
    end

    def action_details
      #required_action_details
      return '' unless @match.dual_application_or_dual_acceptance?

      @match.action_needed? ? required_action_details : last_action_details
    end

    def button
      button_text = 'Confirm initial emails were sent'
      form_path = 'support_interface_record_initial_emails_sent_path(@match)'

      {
        text: button_text,
        path: form_path,
      }
    end

  private

    def type_of_action
      action = if @match.candidate_last_contacted_at.nil?
                  'Send initial emails'
              elsif @match.initial_emails_sent? # && time_to_send_reminder_emails?
                  'Send reminder emails'
              elsif @match.reminder_emails_sent? # && time_to_send_request_withdrawal_from_ucas?
                'Request withdrawal from UCAS'
              else
                'Confirm application was withdrawn from UCAS'
              end

      "<strong class='govuk-tag govuk-tag--red app-tag'>Action needed</strong> #{action}".html_safe
    end

    def required_action_details
      "Use an appropriate templates from <a class='govuk-link' href='https://docs.google.com/document/d/1s5ql4jNUUr3QDPUQYWImkZR6o8upvutrjOEuoZ0qqTE'>this document</a>.<br><br>Please refer to <a class='govuk-link' href='https://docs.google.com/document/d/1XvZiD8_ng_aG_7nvDGuJ9JIdPu6pFdCO2ujfKeFDOk4'>Dual-running user support manual</a> for more information about the current process.".html_safe
    end

    def last_action_details
      last_action = if @match.initial_emails_sent?
                      'sent the initial emails'
                    elsif @match.reminder_emails_sent?
                      'sent the reminder emails'
                    else @match.ucas_withdrawal_requested?
                      'requested for the candidate to be removed from UCAS'
                    end

      "We #{last_action} on the #{@match.candidate_last_contacted_at.to_s(:govuk_date_and_time)}"
    end
  end
end
