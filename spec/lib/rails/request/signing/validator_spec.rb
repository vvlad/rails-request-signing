require 'spec_helper'

describe Rails::Request::Signing::Validator do

  let(:request) {
    double({
      headers: {
        "HTTP_X_SIGNATURE_ID" => "1234",
        "HTTP_X_SIGNATURE" => "153de60c0f481f16a4e229806afa87b27c8b8e8dd62406569d6172f5a7c86cce"
      },
      env: {
        "QUERY_STRING" => "example_param=example_value",
        "RAW_POST_DATA" => "request body"
      }
    })
  }
  subject{ Rails::Request::Signing::Validator.new({secret_key: "1234", access_key: "1234" }, request) }

  it "should be valid" do
    expect{subject.validate!}.not_to raise_error
  end

  it "should raise MissingSignatureKey" do
    request.headers.delete "HTTP_X_SIGNATURE_ID"
    expect{subject.validate!}.to raise_error Rails::Request::Signing::MissingSignatureKey
  end

  it "should raise MissingSignature" do
    request.headers.delete "HTTP_X_SIGNATURE"
    expect{subject.validate!}.to raise_error Rails::Request::Signing::MissingSignatureChecksum
  end


end
