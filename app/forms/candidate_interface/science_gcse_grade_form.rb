# TODO: Refactor
module CandidateInterface
  class ScienceGcseGradeForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :grade,
                  :grades,
                  :award_year,
                  :qualification,
                  :subject,
                  :other_grade,
                  :single_award_grade,
                  :double_award_grade,
                  :gcse_science,
                  :biology_grade,
                  :physics_grade,
                  :chemistry_grade
    validates :biology_grade, presence: true, on: :grades, if: :triple_award?
    validates :chemistry_grade, presence: true, on: :grades, if: :triple_award?
    validates :physics_grade, presence: true, on: :grades, if: :triple_award?
    validates :other_grade, presence: true, if: :grade_is_other?
    validates :award_year, presence: true, on: :award_year
    validates :grade, length: { maximum: 6 }, unless: :international_gcses_flag_active?, on: :grade
    validate :grade_length, on: :grade
    validate :award_year_is_a_valid_date, if: :award_year, on: :award_year
    validate :validate_grade_format, unless: :new_record?, on: :grade
    validate :triple_award_grades_format, if: :triple_award?, on: :grade

    class << self
      Grade = Struct.new(:value, :option)

      def single_award_grades
        SINGLE_GCSE_GRADES
      end

      def double_award_grades
        DOUBLE_GCSE_GRADES
      end

      def build_from_qualification(qualification)
        if FeatureFlag.active?('international_gcses') && qualification.qualification_type == 'non_uk'
          new(
            grade: qualification.set_grade,
            other_grade: qualification.set_other_grade,
            award_year: qualification.award_year,
            qualification: qualification,
          )
        else
          new(build_params_from(qualification))
        end
      end

    private

      def build_params_from(qualification)
        params = {
          gcse_science: qualification.subject,
          subject: qualification.subject,
          award_year: qualification.award_year,
          qualification: qualification,
        }

        case qualification.subject
        when ApplicationQualification::SCIENCE_SINGLE_AWARD
          params[:single_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_DOUBLE_AWARD
          params[:double_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_TRIPLE_AWARD
          grades = qualification.grades
          return unless grades

          params[:biology_grade] = grades['biology']
          params[:chemistry_grade] = grades['chemistry']
          params[:physics_grade] = grades['physics']
        when 'science'
          params[:grade] = qualification.grade
        end

        params
      end
    end

    def save_grades
      if !valid?(:grade)
        log_validation_errors(:grade)
        return false
      end

      triple_award_grades = {
        biology: biology_grade,
        physics: physics_grade,
        chemistry: chemistry_grade,
      }

      qualification.update(grade: set_grade, grades: triple_award_grades, subject: subject)
    end

    def save_year
      if valid?(:award_year)
        qualification.update(grade: set_grade, award_year: award_year)
        return true
      end

      false
    end

  private

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
      return if qualification.qualification_type.nil? ||
        qualification.qualification_type == 'other_uk' ||
        qualification.qualification_type == 'non_uk' ||
        grade.nil? ||
        subject == ApplicationQualification::SCIENCE_TRIPLE_AWARD

      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      if qualification_rexp && grade.match(qualification_rexp)
        if subject == ApplicationQualification::SCIENCE_SINGLE_AWARD
          errors.add(:single_award_grade, :invalid)
        elsif subject == ApplicationQualification::SCIENCE_DOUBLE_AWARD
          errors.add(:double_award_grade, :invalid)
        else
          errors.add(:grade, :invalid)
        end
      end
    end

    def triple_award_grades_format
      return unless triple_award?

      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      if qualification_rexp && biology_grade.match(qualification_rexp)
        errors.add(:biology_grade, :invalid)
      end

      if qualification_rexp && chemistry_grade.match(qualification_rexp)
        errors.add(:chemistry_grade, :invalid)
      end

      if qualification_rexp && physics_grade.match(qualification_rexp)
        errors.add(:physics_grade, :invalid)
      end
    end

    def grade_length
      if grade.blank? && subject == ApplicationQualification::SCIENCE_SINGLE_AWARD
        errors.add(:single_award_grade, :blank)
      elsif grade.blank? && subject == ApplicationQualification::SCIENCE_DOUBLE_AWARD
        errors.add(:double_award_grade, :blank)
      elsif subject == ApplicationQualification::SCIENCE_TRIPLE_AWARD
        if biology_grade.blank?
          errors.add(:biology_grade, :blank)
        end

        if chemistry_grade.blank?
          errors.add(:chemistry_grade, :blank)
        end

        if physics_grade.blank?
          errors.add(:physics_grade, :blank)
        end
      elsif grade.blank?
        errors.add(:grade, :blank)
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

    def triple_award?
      subject == ApplicationQualification::SCIENCE_TRIPLE_AWARD
    end
  end
end
