module CandidateInterface
  class ReferenceForm
    include ActiveModel::Model
    attr_accessor :name, :email_address, :relationship, :application_form, :application_reference

    def self.load_from_reference(application_reference)
      new(
        name: application_reference.name,
        email_address: application_reference.email_address,
        relationship: application_reference.relationship,
        application_reference: application_reference,
      )
    end

    def save
      @application_reference ||= application_form.application_references.build

      if @application_reference.update(name: name, email_address: email_address, relationship: relationship)
        true
      else
        # TODO: move all model validations into this form object
        @application_reference.errors.each do |key, message|
          errors[key] << message
        end

        false
      end
    end
  end
end
