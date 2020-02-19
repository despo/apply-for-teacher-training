class FeatureFlag
  FEATURES = %w[
    pilot_open
    training_with_a_disability
    edit_application
    send_dfe_sign_in_invitations
    improved_expired_token_flow
    work_breaks
    experimental_api_features
    confirm_conditions
    show_new_referee_needed
    automated_referee_chaser
    automated_provider_chaser
    provider_change_response
    send_reference_confirmation_email
    automated_referee_replacement
    candidate_rejected_by_provider_email
    notify_candidate_of_new_reference
    automated_decline_by_default_candidate_chaser
    decline_by_default_notification_to_candidate
    offer_accepted_provider_emails
  ].freeze

  def self.activate(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.activate(feature_name)
  end

  def self.deactivate(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.deactivate(feature_name)
  end

  def self.active?(feature_name)
    raise unless feature_name.in?(FEATURES)

    rollout.active?(feature_name)
  end

  def self.rollout
    @rollout ||= Rollout.new(Redis.current)
  end
end
