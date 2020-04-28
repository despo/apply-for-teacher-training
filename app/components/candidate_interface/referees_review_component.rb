module CandidateInterface
  class RefereesReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
      @application_form = application_form
      @editable = editable
      @heading_level = heading_level
      @show_incomplete = show_incomplete
      @missing_error = missing_error
    end

    def referee_rows(referee)
      [
        name_row(referee),
        email_row(referee),
        reference_type_row(referee),
        relationship_row(referee),
        feedback_status_row(referee),
      ].compact
    end

    def minimum_references
      ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

    def show_missing_banner?
      @show_incomplete && @application_form.application_references.count < minimum_references && @editable
    end

  private

    attr_reader :application_form

    def name_row(referee)
      {
        key: 'Name',
        value: referee.name,
        action: "name for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def email_row(referee)
      {
        key: 'Email address',
        value: referee.email_address,
        action: "email address for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def relationship_row(referee)
      {
        key: 'Relationship',
        value: referee.relationship,
        action: "relationship for #{referee.name}",
        change_path: candidate_interface_edit_referee_path(referee.id),
      }
    end

    def reference_type_row(referee)
      {
        key: 'Reference type',
        value: referee.referee_type ? referee.referee_type.capitalize.dasherize : '',
        action: "reference type for #{referee.name}",
        change_path: candidate_interface_referees_type_path(referee.id),
      }
    end

    def feedback_status_row(referee)
      return nil unless show_status?(referee)

      {
        key: 'Status',
        value: feedback_status_label(referee),
      }
    end

    def show_status?(referee)
      referee.application_form.submitted?
    end

    def feedback_status_label(reference)
      render(
        TagComponent.new(
          text: feedback_status_text(reference),
          type: feedback_status_colour(reference),
        ),
      )
    end

    def feedback_status_text(reference)
      return t('candidate_reference_status.feedback_overdue') if reference.feedback_overdue?

      t("candidate_reference_status.#{reference.feedback_status}")
    end

    def feedback_status_colour(reference)
      case reference.feedback_status
      when 'not_requested_yet', 'feedback_requested'
        reference.feedback_overdue? ? :red : :blue
      when 'feedback_provided'
        :green
      when 'feedback_refused', 'feedback_overdue', 'email_bounced', 'cancelled'
        :red
      end
    end
  end
end
