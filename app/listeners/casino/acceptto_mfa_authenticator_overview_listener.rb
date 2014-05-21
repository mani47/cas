require_relative 'listener'

class CASino::AccepttoMfaAuthenticatorOverviewListener < CASino::Listener
  def user_not_logged_in
    # nothing to do here
  end

  def acceptto_mfa_authenticator_found(acceptto_mfa_authenticator)
    assign(:acceptto_mfa_authenticator, acceptto_mfa_authenticator)
  end
end
