class ApplicationReference < ApplicationRecord
  self.table_name = 'references'

  belongs_to :application_form

  audited associated_with: :application_form

  # TODO: remove once `feedback_status` is deployed on all environments
  scope :completed, -> { where('feedback IS NOT NULL') }

  enum feedback_status: {
    not_requested_yet: 'not_requested_yet',
    feedback_requested: 'feedback_requested',
    feedback_provided: 'feedback_provided',
    feedback_refused: 'feedback_refused',
  }

  def ordinal
    self.application_form.application_references.find_index(self).to_i + 1
  end

  def update_token!
    unhashed_token, hashed_token = Devise.token_generator.generate(ApplicationReference, :hashed_sign_in_token)
    update!(hashed_sign_in_token: hashed_token, feedback_status: 'feedback_requested')
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(ApplicationReference, :hashed_sign_in_token, unhashed_token)
    find_by(hashed_sign_in_token: hashed_token)
  end
end
