module SupportInterface
  class ApplicationsExport
    def applications
      audits = Audited::Audit.where(action: 'update', auditable_type: 'ApplicationForm')
        .order(created_at: :desc).pluck(:auditable_id, :audited_changes, :created_at).to_a

      applications_of_interest = relevant_applications

      applications_of_interest.map do |application_form|
        associated_audits = Audited::Audit.where(
          action: 'update',
          associated_type: 'ApplicationForm',
          associated_id: application_form.id,
        ).order(created_at: :desc).pluck(:auditable_type, :created_at).to_a

        output = {
          support_reference: application_form.support_reference,
          process_state: ProcessState.new(application_form).state,
          signed_up_at: application_form.candidate.created_at,
          first_signed_in_at: application_form.created_at,
          submitted_form_at: application_form.submitted_at,
          form_updated_at: application_form.updated_at,
          courses_last_updated_at: associated_audits.find { |a| a[0] == 'ApplicationChoice' }.try(:[], 1),
          qualifications_last_updated_at: associated_audits.find { |a| a[0] == 'ApplicationQualification' }.try(:[], 1),
          work_history_last_updated_at: associated_audits.find { |a| a[0] == 'ApplicationExperience' }.try(:[], 1),
          references_last_updated_at: associated_audits.find { |a| a[0] == 'ApplicationReference' }.try(:[], 1),
        }

        this_application_audits = audits.select { |a| a[0] == application_form.id }

        %w[
          address_line1
          becoming_a_teacher
          country
          course_choices_completed
          date_of_birth
          degrees_completed
          disclose_disability
          english_main_language
          first_name
          first_nationality
          further_information
          interview_preferences
          last_name
          other_qualifications_completed
          phone_number
          postcode
          second_nationality
          subject_knowledge
          volunteering_completed
          volunteering_experience
          work_history_breaks
          work_history_completed
        ].each do |column|
          # these are sorted by audit date, so the first time a given field appears
          # in the audit set is the last time it was touched
          value = this_application_audits.find { |audit| audit[1].key?(column) }.try(:[], 2)
          output[:"#{column}_last_updated_at"] = value
        end

        output
      end
    end

  private

    def relevant_applications
      ApplicationForm.includes(:candidate, :application_choices).where('candidates.hide_in_reporting' => false)
    end
  end
end
