module Rails::Request::Signing

  class SigningError < StandardError
  end

  class MissingSignatureKey < SigningError
  end

  class MissingSignatureChecksum < SigningError
  end

  class BadSignatureError < SigningError
  end


  class Validator

    delegate :env, :headers, to: :@request

    def initialize(credentials, request)
      @credentials = credentials
      @request = request
    end


    def validate!

      error = if missing_access_key?
        Rails::Request::Signing::MissingSignatureKey.new("missing X-Signature-ID header")
      elsif missing_signature?
        Rails::Request::Signing::MissingSignatureChecksum.new("missing X-Signature header")
      elsif invalid_signature?
        Rails::Request::Signing::BadSignatureError.new("Bad signature #{provided_signature} expected #{expected_signature}")
      end

      raise error if error

    end

    def signer_identityfier
      headers["HTTP_X_SIGNATURE_ID"]
    end

    protected
    def missing_access_key?
      ! headers.key?("HTTP_X_SIGNATURE_ID")
    end


    def missing_signature?
      ! headers.key?("HTTP_X_SIGNATURE")
    end


    def invalid_signature?
      provided_signature.blank? or secret_key.blank? or expected_signature != provided_signature
    end

    def expected_signature
      @expected_signature ||= begin
        buffer = "#{secret_key}#{env["QUERY_STRING"]}#{env["RAW_POST_DATA"]}"
        checksum = Digest::SHA2.hexdigest(buffer)
      end if secret_key
    end

    def secret_key
      @credentials[:secret_key]
    end

    def provided_signature
      @provided_signature ||= headers["HTTP_X_SIGNATURE"]
    end


  end
end
