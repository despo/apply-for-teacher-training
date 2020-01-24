module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: :authenticate

    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.for_email candidate_params[:email_address]

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        add_identity_to_log @candidate.id
        redirect_to candidate_interface_check_email_sign_in_path
      elsif @candidate.valid?
        AuthenticationMailer.sign_in_without_account_email(to: @candidate.email_address).deliver_now
        redirect_to candidate_interface_check_email_sign_in_path
      else
        render :new
      end
    end

    def authenticate
      candidate = FindCandidateByToken.call(raw_token: params[:token])

      if candidate

        sign_in(candidate, scope: :candidate)
        add_identity_to_log candidate.id
        course_id = candidate.course_from_find_id
        first_login = candidate.first_login?
        service = ExistingCandidateAuthentication.new(candidate: candidate).execute

        if service == :candidate_has_new_course_added
          account_created_flash_if_new_user(first_login)

          redirect_to candidate_interface_course_choices_review_path
        elsif service == :candidate_should_choose_site
          course = Course.find(course_id)
          account_created_flash_if_new_user(first_login)

          redirect_to candidate_interface_course_choices_site_path(course.provider.code, course.code)
        elsif service == :candidate_does_not_have_a_course_from_find_id
          account_created_flash_if_new_user(first_login)

          redirect_to candidate_interface_application_form_path
        elsif service == :candidate_already_has_3_courses
          course = Course.find(course_id)
          flash[:warning] = "You cannot have more than 3 course choices. You must delete a choice if you want to apply to #{course.name_and_code}."
          redirect_to candidate_interface_course_choices_review_path
        end
      else
        redirect_to action: :new
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end

    def account_created_flash_if_new_user(first_login)
      flash[:success] = "Your apply for teacher training account has been created" if first_login
    end
  end
end
