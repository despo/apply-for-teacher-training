module SupportInterface
  class PersonaExport
    include GeocodeHelper

    def data_for_export
      application_choices.find_each.map do |application_choice|
        application_form = application_choice.application_form

        {
          'Candidate id' => application_form.candidate_id,
          'Support reference' => application_form.support_reference,
          'Age' => return_age(application_form),
          'Candidate postcode' => application_form.postcode,
          'Provider postcode' => application_choice.provider.postcode,
          'Site postcode' => application_choice.site.postcode,
          'Site region' => application_choice.site.region,
          'Provider type' => application_choice.provider.provider_type,
          'Accrediting provider type' => application_choice.course.accredited_provider&.provider_type,
          'Program type' => application_choice.course.program_type,
          'Degree completed' => return_lastest_degree_award_year(application_form),
          'Degree type' => return_lastest_degree_type(application_form),
          'Distance from site to candidate' => distance(application_choice),
          'Average distance from all sites to candidate' => average_distance(application_form),
          'Rejection reason' => application_choice.rejection_reason,
          'Structured rejection reasons' => FlatReasonsForRejectionPresenter.build_top_level_reasons(application_choice.structured_rejection_reasons),
          'Application status' => I18n.t!("candidate_flow_application_states.#{ProcessState.new(application_form).state}.name"),
          'Course code' => application_choice.course.code,
          'Provider code' => application_choice.provider.code,
          'Nationality' => nationality(application_choice),
          'Rejected by default at' => application_choice.reject_by_default_at,
          'Link to application' => application_url(application_form),
        }
      end
    end

  private

    def application_choices
      ApplicationChoice
      .includes(%i[application_form site provider course candidate])
      .joins(:candidate)
      .merge(Candidate.order(:id))
    end

    def return_age(application_form)
      ((Time.zone.now.to_date - application_form.date_of_birth) / 365).floor if application_form.date_of_birth.present?
    end

    def return_lastest_degree_type(application_form)
      latest_degree(application_form)&.qualification_type
    end

    def return_lastest_degree_award_year(application_form)
      latest_degree(application_form)&.award_year
    end

    def latest_degree(application_form)
      degrees_with_award_year = application_form.application_qualifications.degree.select { |degree| degree.award_year.present? }

      return nil if degrees_with_award_year.blank?

      degrees_with_award_year.max_by(&:award_year)
    end

    def distance(application_choice)
      format_distance(
        application_choice.application_form,
        application_choice&.site, with_units: false
      )
    end

    def average_distance(application_form)
      format_average_distance(
        application_form,
        application_form.application_choices.map(&:site),
        with_units: false,
      )
    end

    def nationality(application_choice)
      ApplicationChoiceHesaExportDecorator.new(application_choice).nationality
    end

    def application_url(application_form)
      "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}"
    end
  end
end
