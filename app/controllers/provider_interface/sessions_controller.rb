module ProviderInterface
  class SessionsController < ProviderInterfaceController
    def new
    end

    def callback
      session[:user_first_name] = auth_hash['info']['first_name']
      redirect_to provider_interface_path
    end

    def sign_out
      session.destroy
      redirect_to provider_interface_sign_in_path
    end

  private

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
