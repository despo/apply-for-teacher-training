module CandidateInterface
  class ReferenceForm
    include ActiveModel::Model
    attr_accessor :name, :email_address, :relationship, :application_form, :application_reference

    validates :name, presence: true, length: { minimum: 2, maximum: 200 }
    validates :relationship, presence: true, word_count: { maximum: 50 }
    validates :email_address, presence: true,
                              email_address: true,
                              length: { maximum: 100 }

    validate :email_address_not_own
    validate :email_address_not_used_twice

    def self.load_from_reference(application_reference)
      new(
        name: application_reference.name,
        email_address: application_reference.email_address,
        relationship: application_reference.relationship,
        application_reference: application_reference,
      )
    end

    def save
      return unless valid?

      @application_reference ||= application_form.application_references.build
      @application_reference.update(name: name, email_address: email_address, relationship: relationship)
    end

  private

    def email_address_not_used_twice
      other_references = application_form.application_references.except(application_reference)
      if other_references.any? { |reference| reference.email_address == email_address }
        errors.add(:email_address, :taken)
      end
    end

    def email_address_not_own
      return if self.application_form.nil?

      candidate_email_address = self.application_form.candidate.email_address

      errors.add(:email_address, :own) if email_address == candidate_email_address
    end
  end
end
