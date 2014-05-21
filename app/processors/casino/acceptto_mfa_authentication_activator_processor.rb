# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::AccepttoMfaAuthenticationActivatorProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  # The method will call one of the following methods on the listener:
  # * `#user_not_logged_in`: The user is not logged in and should be redirected to /login.
  # * `#two_factor_authenticator_activated`: The two-factor authenticator was successfully activated.
  # * `#invalid_two_factor_authenticator`: The two-factor authenticator is not valid.
  # * `#invalid_one_time_password`: The user should be asked for a new OTP.
  #
  # @param [Hash] params parameters supplied by user. The processor will look for keys :access_token.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    cookies ||= {}
    params ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      if params[:error].present? || !params[:access_token].present?
        @listener.invalid_mfa_authenticator
      else
        tgt.user.acceptto_authenticators.delete_all
        tgt.user.acceptto_authenticators.create( :token => params[:access_token], :authenticated => true )
        @listener.mfa_authenticator_activated
      end
    end
  end
end
