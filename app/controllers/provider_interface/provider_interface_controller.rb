module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    layout 'application'

  private

    def authenticate_provider_user!
      unless current_user
        redirect_to provider_interface_sign_in_path
      end
    end

    def current_user
      return unless session[:user_first_name]

      fake_user_class = Struct.new(:provider, :name)
      fake_provider_class = Struct.new(:code)
      fake_user_class.new(fake_provider_class.new('ABC'), session[:user_first_name])
    end

    helper_method :current_user
  end
end
