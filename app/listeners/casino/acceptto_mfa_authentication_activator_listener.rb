require_relative 'listener'

class CASino::AccepttoMfaAuthenticationActivatorListener < CASino::Listener
  def user_not_logged_in
    @controller.redirect_to login_path
  end

  def mfa_authenticator_activated
    @controller.flash[:notice] = I18n.t('acceptto_mfa_authenticator.successfully_activated')
    @controller.redirect_to sessions_path
  end

  def invalid_mfa_authenticator
    @controller.flash[:error] = I18n.t('acceptto_mfa_authenticator.invalid_mfa_authenticator')
    @controller.redirect_to sessions_path
  end
end
