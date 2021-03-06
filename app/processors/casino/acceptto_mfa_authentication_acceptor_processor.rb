# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::AccepttoMfaAuthenticationAcceptorProcessor < CASino::Processor
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::TicketGrantingTickets
  include CASino::ProcessorConcern::AccepttoMfaAuthenticators

  # The method will call one of the following methods on the listener:
  # * `#user_not_logged_in`: The user should be redirected to /login.
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  #   The second argument (String) is the ticket-granting ticket. It should be stored in a cookie named "tgt".
  # * `#invalid_mfa_request`: The Multi Factor Authentication request denied.
  #
  # @param [Hash] params parameters supplied by user. The processor will look for keys :channel and :service.
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, user_agent = nil, session = nil)
    p "CASINO Processing Acceptto MFA with Param: #{params}"
    cookies ||= {}
    p "params[:tgt] is #{params[:tgt]}"
    tgt = find_valid_ticket_granting_ticket(params[:tgt], user_agent, true)
    p "TGT is #{tgt}"

    #dirty hack to solve a weird bug
    unless params["amp;service"].blank?
      params[:service] = params["amp;service"]
    end

    if tgt.nil?
      @listener.user_not_logged_in
    else
	    if !session.nil? and session[:channel].blank?
		    return @listener.invalid_mfa_request(params[:service])
	    end

	    channel = session[:channel] unless session.nil?
	    p "******************************************"
	    p "Channel in proccessor is: #{channel}"
	    p "******************************************"

      unless params[:service].blank?
        p "******************************************"
        p "Service is #{params["service"]}"
        p "******************************************"
      end

	    session[:channel] = '' unless session.nil?
      validation_result = check(tgt, channel)
      if validation_result.success?
        tgt.awaiting_acceptto_authentication = false
        tgt.save!
        begin
          url = unless params[:service].blank?
            acquire_service_ticket(tgt, params[:service], true).service_with_ticket_url
          end
          if tgt.long_term?
            @listener.user_logged_in(url, tgt.ticket, CASino.config.ticket_granting_ticket[:lifetime_long_term].seconds.from_now)
          else
            @listener.user_logged_in(url, tgt.ticket)
          end
        rescue ServiceNotAllowedError => e
          @listener.service_not_allowed(clean_service_url params[:service])
        end
      else
        @listener.invalid_mfa_request(params[:service])
      end
    end
  end
end
