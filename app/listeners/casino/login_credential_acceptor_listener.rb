require_relative 'listener'

class CASino::LoginCredentialAcceptorListener < CASino::Listener
  def user_logged_in(url, ticket_granting_ticket, cookie_expiry_time = nil)
    @controller.cookies[:tgt] = { value: ticket_granting_ticket, expires: cookie_expiry_time }
    if url.nil?
      @controller.redirect_to sessions_path, status: :see_other
    else
      @controller.redirect_to url, status: :see_other
    end
  end

  def two_factor_authentication_pending(ticket_granting_ticket)
    assign(:ticket_granting_ticket, ticket_granting_ticket)
    @controller.render 'validate_otp'
  end
  
  def acceptto_authentication_pending(ticket_granting_ticket)
    assign(:ticket_granting_ticket, ticket_granting_ticket.ticket)
    acceptto = Acceptto::Client.new(Rails.configuration.mfa_app_uid, Rails.configuration.mfa_app_secret, '')
    @channel = acceptto.authenticate(ticket_granting_ticket.acceptto_authentication_token, I18n.t("acceptto_mfa_authenticator.wishing_to_authorize"), I18n.t("acceptto_mfa_authenticator.mfa_authetication_type"))
    @controller.render 'validate_mfa', :locals => { :channel => @channel }
  end

  def invalid_login_credentials(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_credentials')
    rerender_login_page(login_ticket)
  end

  def invalid_login_ticket(login_ticket)
    @controller.flash.now[:error] = I18n.t('login_credential_acceptor.invalid_login_ticket')
    rerender_login_page(login_ticket)
  end

  def service_not_allowed(service)
    assign(:service, service)
    @controller.render 'service_not_allowed', status: 403
  end

  private
  def rerender_login_page(login_ticket)
    assign(:login_ticket, login_ticket)
    @controller.render 'new', status: 403
  end
end
