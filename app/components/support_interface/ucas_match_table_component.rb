module SupportInterface
  class UCASMatchTableComponent < ViewComponent::Base
    include ViewHelper

    def initialize(match)
      @match = match
      @summary = applied_on_both_services? ? 'This applicant has applied to the same course on both services.' : 'This applicant has applied on both services but not for the same course.'
    end

    def table_rows
      candidates_course_choices.map do |course|
        row_data = {
          course_code: course_code(course),
          course_details: course_details(course),
          course_provider_contacts: course_provider_contacts(course),
        }

        matched_applications_for_course(course).each do |ucas_matched_application|
          status = ucas_matched_application.status

          if ucas_matched_application.ucas_scheme?
            row_data.merge!(status_on_ucas: status, status_on_apply: 'N/A')
          elsif ucas_matched_application.dfe_scheme?
            row_data.merge!(status_on_ucas: 'N/A', status_on_apply: status)
          else
            row_data.merge!(
              status_on_ucas: ucas_matched_application.mapped_ucas_status,
              status_on_apply: status,
            )
          end
        end

        row_data
      end
    end

  private

    def candidates_course_choices
      ucas_matched_applications.map(&:course).uniq
    end

    def ucas_matched_applications
      @match.ucas_matched_applications
    end

    def matched_applications_for_course(course)
      ucas_matched_applications.select { |application| application.course == course }
    end

    def applied_on_both_services?
      ucas_matched_applications.map(&:both_scheme?).any?
    end

    def course_code(course)
      course.code
    end

    def course_details(course)
      "#{course.name} – #{course.provider&.name || 'Provider not on Apply'}"
    end

    def course_provider_contacts(course)
      return [] if course.provider.blank?

      course.provider.provider_users.select { |u| u.provider_permissions.map(&:manage_users).any? }
    end
  end
end
