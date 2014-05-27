require 'addressable/uri'

module CASino
  module ProcessorConcern
    module AccepttoMfaAuthenticators
      class ValidationResult < CASino::ValidationResult; end

      def check(token, channel)
        acceptto = Acceptto::Client.new(Rails.configuration.mfa_app_uid, Rails.configuration.mfa_app_secret, '')
        status = acceptto.mfa_check(token, channel)
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
