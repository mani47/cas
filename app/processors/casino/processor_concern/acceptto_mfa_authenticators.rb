require 'addressable/uri'

module CASino
  module ProcessorConcern
    module AccepttoMfaAuthenticators
      class ValidationResult < CASino::ValidationResult; end

      def check(tgt, channel)
        # acceptto = Acceptto::Client.new(Rails.configuration.mfa_app_uid, Rails.configuration.mfa_app_secret, '')
        # status = acceptto.mfa_check(token, channel)

        p "*****************************************************************"
        p "inside AccepttoMfaAuthenticators.check"
        p "*****************************************************************"

        response = RestClient.post "#{Rails.configuration.mfa_site}/api/v9/check",
                                   { 'channel' => channel,
                                     'email' => tgt.user.username
                                   },
                                   :content_type => :json, :accept => :json
        resp = JSON.parse(response.body)

        p "*****************************************************************"
        p "AccepttoMfaAuthenticators.check result: #{resp}"
        p "*****************************************************************"
        status = resp['status']

        if status == "approved"
          ValidationResult.new
        elsif status == "rejected"
          ValidationResult.new 'REJECTED_MFA', 'MFA request rejected!', :warn
        else
          ValidationResult.new 'TIMEOUT_MFA', 'MFA request timed out.', :warn
        end
      end
    end
  end
end
