module CandidateInterface
  class WelcomeController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show
      @contact_details_form = ContactDetailsForm.new(application_form)

      redirect_to candidate_interface_welcome_path if params[:token]
    end

    def update
      form = ContactDetailsForm.new(params[:x])
      form.save
    end

    class ContactDetailsForm
      include ActiveModel::Model
      attr_access :first_name
      validates_present_of :first_name

      def load(application_form)
        # buid from self
      end

      def save
        application_form.update!(

        )
      end
    end
  end
end
