module ProviderInterface
  class ApplicationChoicePresenter
    def initialize(application_choice)
      @application_choice = application_choice
      @application_form = application_choice.application_form
    end

    def status_tag_text
      application_choice.status.humanize.titleize
    end

    def status_tag_class
      case application_choice.status
      when 'offer'
        'app-tag--offer'
      when 'rejected'
        'app-tag--rejected'
      else
        'app-tag--new'
      end
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def course_name_and_code
      application_choice.course.name_and_code
    end

    def course_start_date
      application_choice.course.start_date
    end

    def course_preferred_location
      application_choice.course.course_options.first.site.name
    end

    def status_name
      I18n.t!("application_choice.status_name.#{status}")
    end

    def updated_at
      application_choice.updated_at.strftime('%e %b %Y %l:%M%P')
    end

    def to_param
      application_choice.to_param
    end

  private

    delegate :email_address, to: :candidate
    delegate :candidate, :phone_number, :date_of_birth, :first_name, :last_name, to: :application_form
    delegate :id, :status, to: :application_choice

    attr_reader :application_choice, :application_form
  end
end
