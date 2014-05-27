require_relative 'listener'

class CASino::AccepttoMfaAuthenticationAcceptorListener < CASino::Listener
  
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def user_logged_in(url, ticket_granting_ticket, cookie_expiry_time = nil)
    @controller.cookies[:tgt] = { value: ticket_granting_ticket, expires: cookie_expiry_time }
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end

  def invalid_mfa_request
    @controller.flash.now[:error] = I18n.t('acceptto_mfa_authenticator.invalid_mfa_request')
  end

  def service_not_allowed(service)
    assign(:service, service)
    @controller.render 'service_not_allowed', status: 403
  end
end
