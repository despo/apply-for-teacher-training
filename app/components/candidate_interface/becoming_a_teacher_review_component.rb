module CandidateInterface
  class BecomingATeacherReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, missing_error: false)
      @application_form = application_form
      @becoming_a_teacher_form = CandidateInterface::BecomingATeacherForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
    end

    def becoming_a_teacher_form_rows
      [becoming_a_teacher_form_row]
    end

    def show_missing_banner?
      !@becoming_a_teacher_form.valid? && @editable
    end

  private

    attr_reader :application_form

    def becoming_a_teacher_form_row
      {
        key: t('application_form.personal_statement.becoming_a_teacher.label'),
        value: @becoming_a_teacher_form.becoming_a_teacher,
        action: t('application_form.personal_statement.becoming_a_teacher.change_action'),
        change_path: Rails.application.routes.url_helpers.candidate_interface_becoming_a_teacher_edit_path,
      }
    end
  end
end
