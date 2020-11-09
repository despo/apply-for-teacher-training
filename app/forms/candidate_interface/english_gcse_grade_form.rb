module CandidateInterface
  class EnglishGcseGradeForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :grade,
                  :award_year,
                  :qualification,
                  :other_grade,
                  :grades,
                  :english_gcses,
                  :english,
                  :grade_english,
                  :english_language,
                  :grade_english_language,
                  :english_literature,
                  :grade_english_literature,
                  :english_studies,
                  :grade_english_studies,
                  :other_english_gcse,
                  :other_english_gcse_name,
                  :grade_other_english_gcse

    validates :grade, presence: true, on: :grade
    validates :other_grade, presence: true, if: :grade_is_other?
    validates :award_year, presence: true, on: :award_year
    validates :grade, length: { maximum: 6 }, on: :grade, unless: :international_gcses_flag_active?
    validate :award_year_is_a_valid_date, if: :award_year, on: :award_year
    validate :validate_grade_format, unless: :new_record?, on: :grade

    Grade = Struct.new(:value, :option)

    def self.all_grade_drop_down_options
      ALL_GCSE_GRADES.map { |g| Grade.new(g, g) }.unshift(Grade.new(nil, nil))
    end

    def self.build_from_qualification(qualification)
      if FeatureFlag.active?('international_gcses') && qualification.qualification_type == 'non_uk'
        new(
          grade: qualification.set_grade,
          other_grade: qualification.set_other_grade,
          award_year: qualification.award_year,
          qualification: qualification,
        )
      else
        params = {
          grade: qualification.grade,
          award_year: qualification.award_year,
          qualification: qualification
        }

        if qualification.grades
          grades = JSON.parse(qualification.grades)

          other_english_gcse_name = grades.keys.select {
              |k| ["english", "english_language", "english_literature", "english_studies"].exclude? k}.first

          english_gcses = []
          english_gcses << :english if grades.keys.include? "english"
          english_gcses << :english_language if grades.keys.include? "english_language"
          english_gcses << :english_literature if grades.keys.include? "english_literature"
          english_gcses << :english_studies if grades.keys.include? "english_studies"
          english_gcses << :other_english_gcse if other_english_gcse_name
          params[:english_gcses] = english_gcses

          params[:other_english_gcse_name] = other_english_gcse_name if other_english_gcse_name
          params[:grade_other_english_gcse] = grades[other_english_gcse_name] if other_english_gcse_name
          params[:grade_english] = grades["english"] if grades.keys.include? "english"
          params[:grade_english_language] = grades["english_language"] if grades.keys.include? "english_language"
          params[:grade_english_literature] = grades["english_literature"] if grades.keys.include? "english_literature"
          params[:grade_english_studies] = grades["english_studies"] if grades.keys.include? "english_studies"
        end

        new(params)
      end
    end

    def save_grades
      grades = convert_form_params_to_grades

      # add validation here
      qualification.update(grades: grades)
    end

    def save_grade
      if !valid?(:grade)
        log_validation_errors(:grade)
        return false
      end
      qualification.update(grade: set_grade, award_year: award_year)
    end

    def save_year
      if valid?(:award_year)
        qualification.update(grade: set_grade, award_year: award_year)
        return true
      end

      false
    end

  private

    def convert_form_params_to_grades
      grades = {}.tap do |model|
        model[:english] = grade_english if english
        model[:english_language] = grade_english_language if english_language
        model[:english_literature] = grade_english_literature if english_literature
        model[:english_studies] = grade_english_studies if english_studies
        model[other_english_gcse_name] = grade_other_english_gcse if other_english_gcse
      end
      grades.to_json if grades.any?
    end

    def award_year_is_not_in_the_future
      date_limit = Time.zone.now.year.to_i + 1
      errors.add(:award_year, :in_future, date: date_limit) if award_year.to_i >= date_limit
    end

    def award_year_is_invalid
      errors.add(:award_year, :invalid)
    end

    def award_year_is_a_valid_date
      if valid_year?(award_year)
        award_year_is_not_in_the_future
      else
        award_year_is_invalid
      end
    end

    def validate_grade_format
      return if qualification.qualification_type.nil? || qualification.qualification_type == 'other_uk' || qualification.qualification_type == 'non_uk'

      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      if qualification_rexp && grade.match(qualification_rexp)
        errors.add(:grade, :invalid)
      end
    end

    def invalid_grades
      {
        gcse: /[^1-9A-GU\*\s\-]/i,
        gce_o_level: /[^A-EU\s\-]/i,
        scottish_national_5: /[^A-D1-7\s\-]/i,
      }
    end

    def new_record?
      qualification.nil?
    end

    def log_validation_errors(field)
      return unless errors.key?(field)

      error_message = {
        field: field.to_s,
        error_messages: errors[field].join(' - '),
        value: instance_values[field.to_s],
      }

      Rails.logger.info("Validation error: #{error_message.inspect}")
    end

    def grade_is_other?
      grade == 'other'
    end

    def set_grade
      case grade
      when 'other'
        other_grade
      when 'not_applicable'
        'N/A'
      when 'unknown'
        'Unknown'
      else
        grade
      end
    end

    def international_gcses_flag_active?
      FeatureFlag.active?('international_gcses')
    end
  end
end
