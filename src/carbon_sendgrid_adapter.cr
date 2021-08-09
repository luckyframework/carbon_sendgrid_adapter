require "http"
require "json"
require "carbon"

class Carbon::SendGridAdapter < Carbon::Adapter
  getter authentication_strategy : AuthenticationStrategy
  private getter? sandbox : Bool

  def initialize(api_key : String, @sandbox = false)
    @authentication_strategy = AuthenticationStrategy.new(api_key)
  end

  def initialize(username : String, password : String, @sandbox = false)
    @authentication_strategy = AuthenticationStrategy.new(username, password)
  end

  def deliver_now(email : Carbon::Email)
    Carbon::SendGridAdapter::Email.new(email, authentication_strategy, sandbox?).deliver
  end

  class AuthenticationStrategy
    private getter api_key : String?
    private getter username : String?
    private getter password : String?

    def initialize(@username, @password)
    end

    def initialize(@api_key)
    end

    def authenticate_with_basic_auth?
      api_key.nil?
    end
  end

  class Email
    BASE_URI       = "api.sendgrid.com"
    MAIL_SEND_PATH = "/v3/mail/send"
    private getter email, api_key
    private getter? sandbox : Bool

    def initialize(@email : Carbon::Email, @authentication_strategy : AuthenticationStrategy, @sandbox = false)
    end

    def deliver
      client.post(MAIL_SEND_PATH, body: params.to_json).tap do |response|
        unless response.success?
          raise JSON.parse(response.body).inspect
        end
      end
    end

    # :nodoc:
    # Used only for testing
    def params
      {
        personalizations: [personalizations],
        subject:          email.subject,
        from:             from,
        content:          content,
        headers:          headers,
        reply_to:         reply_to_params,
        mail_settings:    {sandbox_mode: {enable: sandbox?}},
      }
    end

    private def reply_to_params
      if reply_to_address
        {email: reply_to_address}
      end
    end

    private def reply_to_address : String?
      reply_to_header.values.first?
    end

    private def reply_to_header
      email.headers.select do |key, _value|
        key.downcase == "reply-to"
      end
    end

    private def headers : Hash(String, String)
      email.headers.reject do |key, _value|
        key.downcase == "reply-to"
      end
    end

    private def personalizations
      {
        to:  to_send_grid_address(email.to),
        cc:  to_send_grid_address(email.cc),
        bcc: to_send_grid_address(email.bcc),
      }.to_h.reject do |_key, value|
        value.empty?
      end
    end

    private def to_send_grid_address(addresses : Array(Carbon::Address))
      addresses.map do |carbon_address|
        {
          name:  carbon_address.name,
          email: carbon_address.address,
        }
      end
    end

    private def from
      {
        email: email.from.address,
        name:  email.from.name,
      }.to_h.reject do |_key, value|
        value.nil?
      end
    end

    private def content
      [
        text_content,
        html_content,
      ].compact
    end

    private def text_content
      body = email.text_body
      if body && !body.empty?
        {
          type:  "text/plain",
          value: body,
        }
      end
    end

    private def html_content
      body = email.html_body
      if body && !body.empty?
        {
          type:  "text/html",
          value: body,
        }
      end
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(BASE_URI, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          if authentication_strategy.authenticate_with_basic_auth?
            client.basic_auth(authentication_strategy.username, authentication_strategy.password)
          else
            request.headers["Authorization"] = "Bearer #{authentication_strategy.api_key}"
          end
          request.headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
