require "rails/request/signing/version"
module Rails
  module Request
    module Signing

      extend ActiveSupport::Concern

      module ClassMethods
        def requires_signed_request_by!(signer, options={})
          process_signed_request! signer, true, options
        end

        def maybe_signed_request_by!(signer, options={})
          process_signed_request! signer, false, options
        end

        def process_signed_request!(signer, required = true, options={})

          prepend_before_filter(options) do
            break unless required
            helper = method(signer)

            signing_entity = helper.arity.zero? ? helper.call :  helper.call(request.headers["HTTP_X_SIGNATURE_ID"])

            credentials = {}
            credentials = signing_entity.to_credentials if signing_entity.respond_to? :to_credentials

            validator = Validator.new(credentials, request)
            validator.validate!

          end

        end

      end

    end
  end
end



require 'rails/request/signing/validator'


