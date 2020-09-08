module CandidateInterface
  class ContactDetails::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def edit
      @contact_details_form = ContactDetailsForm.build_from_application(
        current_application,
      )
    end

    def update
      @contact_details_form = ContactDetailsForm.new(contact_details_params)

      if @contact_details_form.save_base(current_application)
        updated_contact_details_form = ContactDetailsForm.build_from_application(
          current_application,
        )

        if updated_contact_details_form.valid?(:address)
          current_application.update!(contact_details_completed: false)

          redirect_to candidate_interface_contact_details_review_path
        elsif FeatureFlag.active?(:international_addresses)
          redirect_to candidate_interface_contact_details_edit_address_type_path
        else
          redirect_to candidate_interface_contact_details_new_address_path
        end
      else
        track_validation_error(@contact_details_form)
        render :edit
      end
    end

  private

    def contact_details_params
      params.require(:candidate_interface_contact_details_form).permit(:phone_number)
        .transform_values(&:strip)
    end
  end
end
