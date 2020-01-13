module CandidateInterface
  class RefereesController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable
    before_action :redirect_to_review_referees_if_amendable, except: %i[index review]
    before_action :set_referee, only: %i[edit update confirm_destroy destroy]
    before_action :set_referees, only: %i[index review]

    def index
      unless @referees.empty?
        redirect_to candidate_interface_review_referees_path
      end
    end

    def new
      @referee_form = ReferenceForm.new
    end

    def create
      @referee_form = ReferenceForm.new(referee_params.merge(application_form: current_candidate.current_application))

      if @referee_form.save
        redirect_to candidate_interface_review_referees_path
      else
        render :new
      end
    end

    def edit
      @referee_form = ReferenceForm.load_from_reference(@referee)
    end

    def update
      @referee_form = ReferenceForm.new(referee_params.merge(application_reference: @referee))

      if @referee_form.save
        redirect_to candidate_interface_review_referees_path
      else
        render :edit
      end
    end

    def confirm_destroy; end

    def destroy
      @referee.destroy!
      redirect_to candidate_interface_referees_path
    end

    def review
      @application_form = current_candidate.current_application
    end

  private

    def set_referee
      @referee = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
                                    .find(params[:id])
    end

    def set_referees
      @referees = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
    end

    def referee_params
      params.require(:candidate_interface_reference_form).permit(
        :name,
        :email_address,
        :relationship,
      )
        .transform_values(&:strip)
    end

    def redirect_to_review_referees_if_amendable
      redirect_to candidate_interface_review_referees_path if current_application.amendable?
    end
  end
end
