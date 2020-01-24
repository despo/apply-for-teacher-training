class Candidate < ApplicationRecord
  # Only Devise's :timeoutable module is enabled to handle session expiry
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise :timeoutable

  before_validation :downcase_email
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            length: { maximum: 100 },
                            email_address: true

  has_many :application_forms

  def self.for_email(email)
    find_or_initialize_by(email_address: email.downcase) if email
  end

  def current_application
    application_form = application_forms.first_or_create!
    application_form
  end

  def last_updated_application
    application_forms.max_by(&:updated_at)
  end

  def first_login?
    created_at.to_i == updated_at.to_i
  end

private

  def downcase_email
    email_address.try(:downcase!)
  end
end
