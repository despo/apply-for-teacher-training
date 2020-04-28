module CandidateInterface
  class Volunteering::BaseController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def new
      @volunteering_role = VolunteeringRoleForm.new
    end

    def create
      @volunteering_role = VolunteeringRoleForm.new(volunteering_role_params)

      if @volunteering_role.save(current_application)
        current_application.update!(volunteering_completed: false)

        redirect_to candidate_interface_review_volunteering_path
      else
        track_validation_error(@volunteering_role)
        render :new
      end
    end

    def edit
      current_experience = current_application.application_volunteering_experiences.find(current_volunteering_role_id)
      @volunteering_role = VolunteeringRoleForm.build_from_experience(current_experience)
    end

    def update
      @volunteering_role = VolunteeringRoleForm.new(volunteering_role_params)

      if @volunteering_role.update(current_application)
        current_application.update!(volunteering_completed: false)

        redirect_to candidate_interface_review_volunteering_path
      else
        track_validation_error(@volunteering_role)
        render :edit
      end
    end

  private

    def current_volunteering_role_id
      params.permit(:id)[:id]
    end

    def volunteering_role_params
      params.require(:candidate_interface_volunteering_role_form)
        .permit(
          :id, :role, :organisation, :details, :working_with_children,
          :"start_date(3i)", :"start_date(2i)", :"start_date(1i)",
          :"end_date(3i)", :"end_date(2i)", :"end_date(1i)"
        )
          .transform_keys { |key| start_date_field_to_attribute(key) }
          .transform_keys { |key| end_date_field_to_attribute(key) }
          .transform_values(&:strip)
    end
  end
end
