require 'spec_helper'



describe Rails::Request::Signing do

  include RSpec::Rails::ControllerExampleGroup

  controller(ActionController::Base) do
    include Rails::Request::Signing
    include Rails.application.routes.url_helpers

    requires_signed_request_by! :api_client

    def index
      head :ok
    end

    rescue_from Rails::Request::Signing::SigningError do |e|
      head :unauthorized
    end

    private
    def api_client(access_key)
      keys = {
        '12345' => OpenStruct.new({
          to_credentials: {
            secret_key: '1234'
          }
        })
      }[access_key]
    end

  end

  before do
    routes.draw do
      get '/index', to: "anonymous#index"
    end
  end


  it "should be success" do
    request.headers["HTTP_X_SIGNATURE_ID"] = "12345"
    request.headers["HTTP_X_SIGNATURE"] = "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
    expect(get :index).to be_success
  end

  it "should not be success" do
    expect(get :index).not_to be_success
  end


end
