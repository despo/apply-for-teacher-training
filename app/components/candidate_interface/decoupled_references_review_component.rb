module CandidateInterface
  class DecoupledReferencesReviewComponent < ViewComponent::Base
    attr_reader :references, :references_section_completed, :editable, :style_as_errored, :submitting_application

    def initialize(
      references:,
      references_section_completed:,
      editable: true,
      style_as_errored: false,
      submitting_application: false
    )
      @references = references
      @references_section_completed = references_section_completed
      @editable = editable
      @style_as_errored = style_as_errored
      @submitting_application = submitting_application
    end

    def card_title(reference)
      "#{formatted_reference_type(reference)} reference from #{reference.name}"
    end

    def reference_rows(reference)
      [
        name_row(reference),
        email_row(reference),
        reference_type_row(reference),
        relationship_row(reference),
        feedback_status_row(reference),
      ].compact
    end

    def show_missing_banner?
      submitting_application && !references_section_completed && editable
    end

  private

    def formatted_reference_type(reference)
      reference.referee_type ? reference.referee_type.capitalize.dasherize : ''
    end

    def name_row(reference)
      {
        key: 'Name',
        value: reference.name,
        action: "name for #{reference.name}",
        change_path: candidate_interface_edit_referee_path(reference.id),
      }
    end

    def email_row(reference)
      {
        key: 'Email address',
        value: reference.email_address,
        action: "email address for #{reference.name}",
        change_path: candidate_interface_edit_referee_path(reference.id),
      }
    end

    def relationship_row(reference)
      {
        key: 'Relationship',
        value: reference.relationship,
        action: "relationship for #{reference.name}",
        change_path: candidate_interface_edit_referee_path(reference.id),
      }
    end

    def reference_type_row(reference)
      {
        key: 'Reference type',
        value: formatted_reference_type(reference),
        action: "reference type for #{reference.name}",
        change_path: candidate_interface_referees_type_path(reference.id),
      }
    end

    def feedback_status_row(reference)
      value = feedback_status_label(reference) + feedback_status_content(reference)

      {
        key: 'Status',
        value: value,
      }
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
      if reference.feedback_overdue? && !reference.cancelled_at_end_of_cycle?
        return t('candidate_reference_status.feedback_overdue')
      end

      t("candidate_reference_status.#{reference.feedback_status}")
    end

    def feedback_status_content(reference)
      if reference.not_requested_yet?
        tag.p(t('application_form.referees.info.not_requested_yet'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.feedback_refused?
        tag.p(t('application_form.referees.info.declined'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.cancelled_at_end_of_cycle?
        tag.p(t('application_form.referees.info.cancelled_at_end_of_cycle'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.cancelled?
        tag.p(t('application_form.referees.info.cancelled'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.feedback_overdue?
        tag.p(t('application_form.referees.info.feedback_overdue'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.feedback_requested? && reference.requested_at > Time.zone.now - 5.days
        tag.p(t('application_form.referees.info.awaiting_reference_sent_less_than_5_days_ago'), class: 'govuk-body govuk-!-margin-top-2')
      elsif reference.feedback_requested?
        tag.p(t('application_form.referees.info.awaiting_reference_sent_more_than_5_days_ago'), class: 'govuk-body govuk-!-margin-top-2')
      end
    end

    def feedback_status_colour(reference)
      case reference.feedback_status
      when 'not_requested_yet'
        :grey
      when 'feedback_refused', 'email_bounced'
        :red
      when 'cancelled', 'cancelled_at_end_of_cycle'
        :orange
      when 'feedback_overdue'
        :yellow
      when 'feedback_requested'
        reference.feedback_overdue? ? :yellow : :purple
      when 'feedback_provided'
        :green
      end
    end
  end
end