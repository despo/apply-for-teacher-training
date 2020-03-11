class CourseOption < ApplicationRecord
  belongs_to :course
  belongs_to :site
  has_many :application_choices

  validates :vacancy_status, presence: true
  validate :validate_providers

  enum study_mode: {
    full_time: 'full_time',
    part_time: 'part_time',
  }

  enum vacancy_status: {
    vacancies: 'vacancies',
    no_vacancies: 'no_vacancies',
  }

  def update_vacancy_status_from_detailed_description!(description)
    no_vacancies! and return if description == 'no_vacancies'
    vacancies! and return if description == 'both_full_time_and_part_time_vacancies'

    if description == 'full_time_vacancies'
      vacancies! and return if full_time?
      no_vacancies! and return if part_time?
    elsif description == 'part_time_vacancies'
      vacancies! and return if part_time?
      no_vacancies! and return if full_time?
    end

    raise InvalidVacancyStatusDescriptionError, description
  end

  class InvalidVacancyStatusDescriptionError < StandardError; end

  def validate_providers
    return unless site.present? && course.present?

    return if site.provider == course.provider

    errors.add(:site, 'must have the same Provider as the course')
  end
end
