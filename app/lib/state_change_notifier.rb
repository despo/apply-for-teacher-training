class StateChangeNotifier
  def self.sign_up(candidate)
    helpers = Rails.application.routes.url_helpers
    text = "New sign-up [candidate_id: #{candidate.id}]"
    url = helpers.support_interface_candidate_url(candidate)

    send(text, url)
  end

  def self.call(event, application_choice: nil, application_form: nil)
    helpers = Rails.application.routes.url_helpers

    if application_choice
      provider_name = application_choice.course.provider.name
      course_name = application_choice.course.name_and_code
      applicant = application_choice.application_form.first_name
      application_form_id = application_choice.application_form.id
    end

    case event
    when :submit_application
      text = "#{application_form.first_name} has just submitted their application"
      url = helpers.support_interface_application_form_url(application_form)
    when :send_application_to_provider
      text = "#{applicant}'s application is ready to be reviewed by #{provider_name}"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :make_an_offer
      text = "#{provider_name} has just made an offer to #{applicant}'s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :change_an_offer
      text = "#{provider_name} has just changed an offer for #{applicant}'s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application
      text = "#{provider_name} has just rejected #{applicant}'s application"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :reject_application_by_default
      text = "#{applicant}'s application has just been rejected by default"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :offer_accepted
      text = ":ok: #{applicant} has accepted #{provider_name}'s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :offer_declined
      text = ":no_good: #{applicant} has declined #{provider_name}'s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :withdraw
      text = ":runner: #{applicant} has withdrawn their application for #{course_name} at #{provider_name}"
      url = helpers.support_interface_application_form_url(application_form_id)
    when :withdraw_offer
      text = ":no_good: #{provider_name} has just withdrawn #{applicant}'s offer"
      url = helpers.support_interface_application_form_url(application_form_id)
    else
      raise 'StateChangeNotifier: unsupported state transition event'
    end

    send(text, url)
  end

  def self.send(text, url)
    if RequestStore.store[:disable_slack_messages]
      Rails.logger.info "Sending Slack messages disabled (message: `#{text}`)"
      return
    end

    SlackNotificationWorker.perform_async(text, url)
  end
end
