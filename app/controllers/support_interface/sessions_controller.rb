module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!

    def new
      session['post_dfe_sign_in_path'] ||= support_interface_path
      if FeatureFlag.active?('dfe_sign_in_fallback')
        render :authentication_fallback
      end
    end

    def destroy
      redirect_to dfe_sign_in_user.support_interface_logout_url
    end

    def sign_in_by_email
      render_404 and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      support_user = SupportUser.find_by(email_address: params.dig(:support_user, :email_address).downcase.strip)

      if support_user
        SupportInterface::MagicLinkAuthentication.send_token!(support_user: support_user)
      end

      redirect_to support_interface_check_your_email_path
    end

    def authenticate_with_token
      redirect_to action: :new and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      render_404 and return unless params[:token]

      support_user = SupportInterface::MagicLinkAuthentication.get_user_from_token!(token: params.fetch(:token))

      # Equivalent to calling DfESignInUser.begin_session!
      session['dfe_sign_in_user'] = {
        'email_address' => support_user.email_address,
        'dfe_sign_in_uid' => support_user.dfe_sign_in_uid,
        'first_name' => support_user.first_name,
        'last_name' => support_user.last_name,
        'last_active_at' => Time.zone.now,
      }

      support_user.update!(last_signed_in_at: Time.zone.now)

      redirect_to support_interface_candidates_path
    end
  end
end
