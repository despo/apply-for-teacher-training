class DuplicateApplication
  attr_reader :original_application_form, :target_phase

  def initialize(original_application_form, target_phase:, recruitment_cycle_year: RecruitmentCycle.current_year)
    @original_application_form = original_application_form
    @target_phase = target_phase
    @recruitment_cycle_year = recruitment_cycle_year
  end

  IGNORED_ATTRIBUTES = %w[id created_at updated_at submitted_at course_choices_completed phase support_reference].freeze
  IGNORED_CHILD_ATTRIBUTES = %w[id created_at updated_at application_form_id].freeze

  def duplicate
    attrs = original_application_form.attributes.except(
      *IGNORED_ATTRIBUTES,
    ).merge(
      phase: target_phase,
      previous_application_form_id: original_application_form.id,
      recruitment_cycle_year: @recruitment_cycle_year,
    )

    new_application_form = ApplicationForm.create!(attrs)

    original_application_form.application_work_experiences.each do |w|
      new_application_form.application_work_experiences.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    original_application_form.application_volunteering_experiences.each do |w|
      new_application_form.application_volunteering_experiences.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    original_application_form.application_qualifications.each do |w|
      new_application_form.application_qualifications.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    original_application_form.application_references.where(feedback_status: %w[feedback_provided not_requested_yet cancelled_at_end_of_cycle]).reject(&:feedback_overdue?).each do |w|
      new_application_form.application_references.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )

      references_cancelled_at_eoc = new_application_form.application_references.select(&:cancelled_at_end_of_cycle?)

      if references_cancelled_at_eoc.present?
        references_cancelled_at_eoc.each(&:not_requested_yet!)
      end
    end

    original_application_form.application_work_history_breaks.each do |w|
      new_application_form.application_work_history_breaks.create!(
        w.attributes.except(*IGNORED_CHILD_ATTRIBUTES),
      )
    end

    new_application_form
  end
end
