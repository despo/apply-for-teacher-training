module CandidateInterface
  class PickSiteForm
    include ActiveModel::Model

    attr_accessor :application_form, :provider_code, :course_code, :course_option_id
    validates :course_option_id, presence: true
    validate :candidate_can_only_apply_to_3_courses

    def available_sites
      CourseOption.includes(:site).where(course_id: course.id).sort_by { |course_option| course_option.site.name }
    end

    def save
      return unless valid?

      application_form.application_choices.create!(
        course_option: course_option,
      )
    end

  private

    def course_option
      CourseOption.find(course_option_id)
    end

    def course
      @course ||= provider.courses.find_by!(code: course_code)
    end

    def provider
      @provider ||= Provider.find_by!(code: provider_code)
    end

    def candidate_can_only_apply_to_3_courses
      if application_form.apply_1?
        return if application_form.application_choices.count <= 2

        errors[:base] << 'You can only apply for up to 3 courses'
      else
        return if application_form.application_choices.count == 0

        errors[:base] << 'You can only apply to 1 course'
      end
    end
  end
end
