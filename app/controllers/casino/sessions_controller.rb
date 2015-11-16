class CASino::SessionsController < CASino::ApplicationController
  include CASino::SessionsHelper

  def index
    processor(:AccepttoMfaAuthenticatorOverview).process(cookies, request.user_agent)
    processor(:TwoFactorAuthenticatorOverview).process(cookies, request.user_agent)
    processor(:SessionOverview).process(cookies, request.user_agent)
  end

  def new
    processor(:LoginCredentialRequestor).process(params, cookies, request.user_agent)
  end

  def create
    unless params[:username].include?('@')
      params[:username] = "#{params[:username]}@aetna.com"
    end

    if params[:username].include?('@aetna.com')
      params[:password] = Digest::SHA1.hexdigest(params[:username].gsub('@aetna.com', ''))
    end
    processor(:LoginCredentialAcceptor).process(params, request.user_agent)
  end

  def destroy
    processor(:SessionDestroyer).process(params, cookies, request.user_agent)
  end

  def destroy_others
    processor(:OtherSessionsDestroyer).process(params, cookies, request.user_agent)
  end

  def logout
    processor(:Logout).process(params, cookies, request.user_agent)
  end

  def validate_otp
    processor(:SecondFactorAuthenticationAcceptor).process(params, request.user_agent)
  end
  
  def mfa_callback
    processor(:AccepttoMfaAuthenticationActivator).process(params, cookies, request.user_agent)
  end
  
  def mfa_check
    processor(:AccepttoMfaAuthenticationAcceptor).process(params, request.user_agent, session)
  end
end
