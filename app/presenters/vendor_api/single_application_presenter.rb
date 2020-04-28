module VendorAPI
  class SingleApplicationPresenter
    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def as_json
      hash = {
        id: application_choice.id.to_s,
        type: 'application',
        attributes: {
          status: application_choice.status,
          phase: application_form.phase,
          updated_at: application_choice.updated_at.iso8601,
          submitted_at: application_form.submitted_at.iso8601,
          personal_statement: personal_statement,
          interview_preferences: application_form.interview_preferences,
          reject_by_default_at: application_choice.reject_by_default_at&.iso8601,
          candidate: {
            id: "C#{application_form.candidate.id}",
            first_name: application_form.first_name,
            last_name: application_form.last_name,
            date_of_birth: application_form.date_of_birth,
            nationality: nationalities,
            uk_residency_status: application_form.uk_residency_status,
            english_main_language: application_form.english_main_language,
            english_language_qualifications: application_form.english_language_details,
            other_languages: application_form.other_language_details,
            disability_disclosure: application_form.disability_disclosure,
          },
          contact_details: {
            phone_number: application_form.phone_number,
            address_line1: application_form.address_line1,
            address_line2: application_form.address_line2,
            address_line3: application_form.address_line3,
            address_line4: application_form.address_line4,
            postcode: application_form.postcode,
            country: application_form.country,
            email: application_form.candidate.email_address,
          },
          course: course_info_for(application_choice.course_option),
          references: references,
          qualifications: qualifications,
          work_experience: {
            jobs: work_experience_jobs,
            volunteering: work_experience_volunteering,
            work_history_break_explanation: work_history_breaks,
          },
          offer: offer,
          rejection: get_rejection,
          withdrawal: withdrawal,
          further_information: application_form.further_information,
        },
      }
      if application_choice.status == 'enrolled'
        hash[:attributes][:hesa_itt_data] = hesa_itt_data
      end
      hash
    end

  private

    attr_reader :application_choice, :application_form

    def get_rejection
      if application_choice.rejection_reason?
        {
          reason: application_choice.rejection_reason,
        }
      elsif application_choice.offer_withdrawal_reason?
        {
          reason: application_choice.offer_withdrawal_reason,
        }
      end
    end

    def withdrawal
      return unless application_choice.withdrawn?

      {
        reason: nil, # Candidates aren't able to provide a withdrawal reason yet
        date: application_choice.withdrawn_at.iso8601,
      }
    end

    def nationalities
      [
        application_form.first_nationality,
        application_form.second_nationality,
      ].map { |n| NATIONALITIES_BY_NAME[n] }.compact.uniq
    end

    def course_info_for(course_option)
      {
        recruitment_cycle_year: course_option.course.recruitment_cycle_year,
        provider_code: course_option.course.provider.code,
        site_code: course_option.site.code,
        course_code: course_option.course.code,
        study_mode: course_option.course.study_mode,
      }
    end

    def work_experience_jobs
      application_form.application_work_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def work_experience_volunteering
      application_form.application_volunteering_experiences.map do |experience|
        experience_to_hash(experience)
      end
    end

    def experience_to_hash(experience)
      {
        id: experience.id,
        start_date: experience.start_date.to_date,
        end_date: experience.end_date&.to_date,
        role: experience.role,
        organisation_name: experience.organisation,
        working_with_children: experience.working_with_children,
        commitment: experience.commitment,
        description: experience_description(experience),
      }
    end

    def experience_description(experience)
      return experience.details if experience.working_pattern.blank?

      "Working pattern: #{experience.working_pattern}\n\nDescription: #{experience.details}"
    end

    def references
      application_form.application_references.map do |reference|
        reference_to_hash(reference)
      end
    end

    def reference_to_hash(reference)
      {
        name: reference.name,
        email: reference.email_address,
        relationship: reference.relationship,
        reference: reference.feedback,
      }
    end

    def qualifications
      {
        gcses: qualifications_of_level('gcse').reject(&:missing_qualification?).map { |q| qualification_to_hash(q) },
        degrees: qualifications_of_level('degree').map { |q| qualification_to_hash(q) },
        other_qualifications: qualifications_of_level('other').map { |q| qualification_to_hash(q) },
        missing_gcses_explanation: missing_gcses_explanation(qualifications_of_level('gcse').select(&:missing_qualification?)),
      }
    end

    def qualifications_of_level(level)
      # NOTE: we do it this way so that it uses the already-included relation
      # rather than triggering separate queries, as it does if we use the scopes
      # .gcses .degrees etc
      application_form.application_qualifications.select do |q|
        q.level == level
      end
    end

    def missing_gcses_explanation(gcses)
      gcses
        .map { |gcse| "#{gcse.subject.capitalize} GCSE or equivalent: #{gcse.missing_explanation}" }
        .join("\n\n")
    end

    def qualification_to_hash(qualification)
      {
        id: qualification.id,
        qualification_type: qualification.qualification_type,
        subject: qualification.subject,
        grade: "#{qualification.grade}#{' (Predicted)' if qualification.predicted_grade}",
        award_year: qualification.award_year,
        institution_details: institution_details(qualification),
        awarding_body: qualification.awarding_body,
        equivalency_details: qualification.equivalency_details,
      }
    end

    def institution_details(qualification)
      if qualification.institution_name
        [qualification.institution_name, qualification.institution_country].compact.join(', ')
      end
    end

    def personal_statement
      "Why do you want to become a teacher?: #{application_form.becoming_a_teacher} \n What is your subject knowledge?: #{application_form.subject_knowledge}"
    end

    def offered_course
      offered_option = application_choice.offered_course_option || application_choice.course_option

      {
        course: course_info_for(offered_option),
      }
    end

    def offer
      return nil if application_choice.offer.nil?

      application_choice.offer.merge(offered_course)
    end

    def hesa_itt_data
      {
        sex: '2',
        disability: '00',
        ethnicity: '10',
      }
    end

    def work_history_breaks
      # With the new feature of adding individual work history breaks, `application_form.work_history_breaks`
      # is a legacy column. So we'll need to check if an application form has this value first.
      if application_form.work_history_breaks
        application_form.work_history_breaks
      elsif application_form.application_work_history_breaks.any?
        breaks = application_form.application_work_history_breaks.map do |work_break|
          start_date = work_break.start_date.to_s(:month_and_year)
          end_date = work_break.end_date.to_s(:month_and_year)

          "#{start_date} to #{end_date}: #{work_break.reason}"
        end

        breaks.join("\n\n")
      else
        ''
      end
    end
  end
end
