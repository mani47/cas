# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::AccepttoMfaAuthenticatorOverviewProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  # This method will call `#user_not_logged_in` or `#two_factor_authenticators_found(Enumerable)` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(cookies = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      @listener.acceptto_mfa_authenticator_found(tgt.user.acceptto_authenticators.first)
    end
  end
end
