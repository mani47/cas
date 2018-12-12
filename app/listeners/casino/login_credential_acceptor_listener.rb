require_relative 'listener'
require 'rest-client'

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
  
  def acceptto_authentication_pending(ticket_granting_ticket, service)
    p "************************************************************"
    p "inside acceptto_authentication_pending ..........."
    p "************************************************************"
    response = RestClient.post "#{Rails.configuration.mfa_site}/api/v9/authenticate_with_options",
                               { 'message' => I18n.t("acceptto_mfa_authenticator.wishing_to_authorize"),
                                 'email' => ticket_granting_ticket.user.username,
                                 'uid' => Rails.configuration.mfa_app_uid,
                                 'secret' => Rails.configuration.mfa_app_secret,
                                 'timeout' => '60',
                                 'type' => I18n.t("acceptto_mfa_authenticator.mfa_authetication_type"),
                                 'ip_address' => @controller.request.ip,
                                 'remote_ip_address' => @controller.request.remote_ip
                               },
                               :content_type => :json, :accept => :json
    resp = JSON.parse(response.body)
    @channel = resp['channel']
    assign(:ticket_granting_ticket, ticket_granting_ticket.ticket)

    # acceptto = Acceptto::Client.new(Rails.configuration.mfa_app_uid, Rails.configuration.mfa_app_secret, '')
    # @channel = acceptto.authenticate(ticket_granting_ticket.acceptto_authentication_token, I18n.t("acceptto_mfa_authenticator.wishing_to_authorize"), I18n.t("acceptto_mfa_authenticator.mfa_authetication_type"), {ip_address: @controller.request.ip, remote_ip_address: @controller.request.remote_ip})

    @controller.session[:channel] = @channel
    callback_url = "#{@controller.request.protocol + @controller.request.host_with_port}/cass/mfa/check?tgt=#{ticket_granting_ticket.ticket}"
    callback_url = "#{callback_url}&service=#{service}" unless service.blank?
    redirect_url = "#{Rails.configuration.mfa_site}/mfa/index?channel=#{@channel}&callback_url=#{callback_url}"
    p "**********************************************************************"
    p "acceptto_authentication_pending setting callback_url to #{callback_url}"
    p "**********************************************************************"
    return @controller.redirect_to redirect_url
    #@controller.render 'validate_mfa', :locals => { :channel => @channel }
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
