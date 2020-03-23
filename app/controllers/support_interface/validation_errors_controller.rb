module SupportInterface
  class ValidationErrorsController < SupportInterfaceController
    def index
      @validation_errors = ValidationError.order(created_at: :desc)
    end
  end
end
