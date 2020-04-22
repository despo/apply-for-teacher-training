module ProviderInterface
  class ProviderUsersController < ProviderInterfaceController
    before_action :requires_provider_add_provider_users_feature_flag, only: %i[new create]

    def index
      @provider_users = ProviderUser.visible_to(current_provider_user)
    end

    def new
      unless current_provider_user.can_manage_users?
        flash[:warning] = 'You need specific permissions to manage other providers.'
        return redirect_to provider_interface_provider_users_path
      end

      @form = ProviderUserForm.new(current_provider_user: current_provider_user)
    end

    def create
      @form = ProviderUserForm.new(
        provider_user_params.merge(current_provider_user: current_provider_user),
      )
      provider_user = @form.build
      service = SaveAndInviteProviderUser.new(
        form: @form,
        save_service: SaveProviderUser.new(provider_user: provider_user),
        invite_service: InviteProviderUser.new(provider_user: provider_user),
        new_user: @form.existing_provider_user.blank?,
      )

      render :new and return unless service.call

      flash[:success] = 'Provider user invited'
      redirect_to provider_interface_provider_users_path
    end

  private

    def provider_user_params
      params.require(:provider_interface_provider_user_form)
            .permit(:email_address, :first_name, :last_name, provider_ids: [])
    end

    def requires_provider_add_provider_users_feature_flag
      raise unless FeatureFlag.active?('provider_add_provider_users')
    end
  end
end
