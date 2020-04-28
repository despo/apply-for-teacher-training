module SupportInterface
  class ProviderCoursesTableComponent < ViewComponent::Base
    include ViewHelper

    def initialize(provider:, courses:)
      @provider = provider
      @courses = courses
    end

    def course_rows
      courses.order(:name).map do |course|
        {
          course_link: govuk_link_to(course.name_and_code, support_interface_course_path(course)),
          provider_link: link_to_provider_page(course.provider),
          level: course.level.titleize,
          recruitment_cycle_year: course.recruitment_cycle_year,
          apply_from_find_link: link_to_apply_from_find_page(course),
          link_to_find_course_page: link_to_find_course_page(course),
          accredited_body: link_to_provider_page(course.accredited_provider),
          accredited_body_onboarded: course.accredited_provider&.onboarded?,
        }
      end
    end

    def providers_vary?
      @providers_vary ||= courses.any? { |c| c.provider != provider }
    end

    def accredited_bodies_vary?
      @accredited_bodies_vary ||= courses.any? { |c| c.accredited_provider && c.accredited_provider != provider }
    end

  private

    attr_reader :provider, :courses

    def link_to_apply_from_find_page(course)
      if course.exposed_in_find? && course.open_on_apply?
        govuk_link_to 'Apply from Find (DfE & UCAS)', candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code)
      elsif course.exposed_in_find?
        govuk_link_to 'Apply from Find (UCAS only)', candidate_interface_apply_from_find_path(providerCode: course.provider.code, courseCode: course.code)
      end
    end

    def link_to_find_course_page(course)
      if course.exposed_in_find?
        govuk_link_to 'Find course page', course.find_url
      end
    end

    def link_to_provider_page(provider)
      if provider
        govuk_link_to(
          provider.name_and_code,
          support_interface_provider_path(provider),
        )
      end
    end
  end
end
