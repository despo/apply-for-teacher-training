require 'jwt'

class InviteProviderUser
  DSI_JWT_HMAC = 'HS256'.freeze

  def initialize(provider_user:)
    @provider_user = provider_user
  end

  def call!
    invite_user_to_dfe_sign_in

    send_welcome_email
  end

  def dfe_invite_url
    baseurl = ENV.fetch('DSI_API_URL')
    if baseurl.present?
      "#{baseurl}/services/apply/invitations"
    end
  end

private

  def invite_user_to_dfe_sign_in
    jwt_payload = { iss: 'apply', aud: 'signin.education.gov.uk' }
    token = JWT.encode jwt_payload, ENV['DSI_API_SECRET'], DSI_JWT_HMAC
    auth_string = "Bearer #{token}"
    request_params = {
      sourceId: @provider_user.id,
      given_name: @provider_user.first_name,
      family_name: @provider_user.last_name,
      email: @provider_user.email_address,
      userRedirect: Rails.application.routes.url_helpers.provider_interface_url,
    }

    response = HTTP.auth(auth_string).post dfe_invite_url, json: request_params
    raise DfeSignInAPIError.new(response) unless response.status.success?
  end

  def send_welcome_email
    ProviderMailer.account_created(@provider_user).deliver_later
  end
end

class DfeSignInAPIError < StandardError
  attr_reader :response

  def initialize(response = nil)
    @response = response
    msg = response ? response.status.to_s : 'No response'
    super(msg)
  end

  def errors
    JSON.parse(response.body)['errors'] rescue []
  end
end
