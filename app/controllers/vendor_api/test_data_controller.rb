module VendorAPI
  class TestDataController < VendorAPIController
    before_action :check_this_is_a_test_environment

    MAX_COUNT = 100
    DEFAULT_COUNT = 100

    MAX_COURSES_COUNT = 3
    DEFAULT_COURSES_COUNT = 1

    def regenerate
      GenerateTestData.new(count_param, current_provider).generate
      render json: { data: { message: 'OK, regenerated the test data' } }
    end

    def generate
      application_choices = TestApplications.new.generate_for_provider(
        provider: current_provider,
        courses_per_application: courses_per_application_param,
        count: count_param,
      )

      render json: { data: { ids: application_choices.map { |ac| ac.id.to_s } } }
    rescue TestApplications::NotEnoughCoursesError => e
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    rescue TestApplications::ZeroCoursesPerApplicationError => e
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def clear!
      current_provider.application_choices.map(&:application_form).map(&:candidate).map(&:destroy!)

      render json: { data: { message: 'Applications cleared' } }
    end

  private

    def check_this_is_a_test_environment
      if HostingEnvironment.production?
        render status: :bad_request, json: { data: { message: 'Sorry, you can only generate test data in test environments' } }
      end
    end

    def count_param
      [(params[:count] || DEFAULT_COUNT).to_i, MAX_COUNT].min
    end

    def courses_per_application_param
      [(params[:courses_per_application] || DEFAULT_COURSES_COUNT).to_i, MAX_COURSES_COUNT].min
    end
  end
end
