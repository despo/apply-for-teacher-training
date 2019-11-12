# https://github.com/DFE-Digital/manage-courses-frontend/blob/master/config/initializers/omniauth.rb

ISSUER = 'https://signin-test-oidc-as.azurewebsites.net'.freeze
IDENTIFIER = ENV['DFE_SIGNIN_IDENTIFIER']
SECRET = ENV['DFE_SIGNIN_SECRET']
BASE_URL = 'https://localhost:3000'.freeze # HostingProvider.x

module OmniAuth
  module Strategies
    class OpenIDConnect
      def authorize_uri
        client.redirect_uri = redirect_uri
        opts = {
          response_type: options.response_type,
          scope: options.scope,
          state: new_state,
          nonce: (new_nonce if options.send_nonce),
          hd: options.hd,
          prompt: :consent,
        }
        client.authorization_uri(opts.reject { |_, v| v.nil? })
      end

      def callback_phase
        error = request.params['error_reason'] || request.params['error']
        if error == 'sessionexpired'
          return redirect('/signin')
        elsif error
          raise CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri'])
        elsif request.params['state'].to_s.empty? || request.params['state'] != stored_state
          # Monkey patch: Ensure a basic 401 rack response with no body or header isn't served
          # return Rack::Response.new(['401 Unauthorized'], 401).finish
          return redirect('/auth/failure')
        elsif !request.params['code']
          return fail!(:missing_code, OmniAuth::OpenIDConnect::MissingCodeError.new(request.params['error']))
        else
          options.issuer = issuer if options.issuer.blank?
          discover! if options.discovery
          client.redirect_uri = redirect_uri
          client.authorization_code = authorization_code
          access_token
          super
        end
      rescue CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end
    end
  end
end

class OmniAuth::Strategies::Dfe < OmniAuth::Strategies::OpenIDConnect; end

if ISSUER.present?
  dfe_sign_in_issuer_uri = URI.parse(ISSUER)
  options = {
    name: :dfe,
    discovery: true,
    response_type: :code,
    client_signing_alg: :RS256,
    scope: %i[openid profile email organisation offline_access],
    prompt: %i[consent],
    client_options: {
      port: dfe_sign_in_issuer_uri.port,
      scheme: dfe_sign_in_issuer_uri.scheme,
      host: dfe_sign_in_issuer_uri.host,
      identifier: IDENTIFIER,
      secret: SECRET,
      redirect_uri: "#{BASE_URL}/auth/dfe/callback",
      authorization_endpoint: '/auth',
      jwks_uri: '/certs',
      token_endpoint: '/token',
      userinfo_endpoint: '/me',
    },
  }

  Rails.application.config.middleware.use OmniAuth::Strategies::OpenIDConnect, options

  class DfeSignIn
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if request.path == '/auth/failure'
        response = Rack::Response.new
        response.redirect('/401')
        response.finish
      elsif request.path == '/auth/dfe/callback' && request.params.empty? && !OmniAuth.config.test_mode
        response = Rack::Response.new
        response.redirect('/dfe/sessions/new')
        response.finish
      else
        @app.call(env)
      end
    rescue ActionController::InvalidAuthenticityToken
      response = Rack::Response.new
      response.redirect('/signin')
      response.finish
    end
  end

  Rails.application.config.middleware.insert_before OmniAuth::Strategies::OpenIDConnect, DfeSignIn
end
