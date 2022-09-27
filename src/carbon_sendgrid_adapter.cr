require "http"
require "json"
require "carbon"
require "./errors"
require "./carbon_sendgrid_extensions"

class Carbon::SendGridAdapter < Carbon::Adapter
  VERSION = "0.3.0"
  private getter api_key : String
  private getter? sandbox : Bool

  def initialize(@api_key, @sandbox = false)
  end

  def deliver_now(email : Carbon::Email)
    Carbon::SendGridAdapter::Email.new(email, api_key, sandbox?).deliver
  end

  class Email
    BASE_URI       = "api.sendgrid.com"
    MAIL_SEND_PATH = "/v3/mail/send"
    private getter email, api_key
    private getter? sandbox : Bool

    def initialize(@email : Carbon::Email, @api_key : String, @sandbox = false)
    end

    def deliver
      body = params.to_json
      client.post(MAIL_SEND_PATH, body: body).tap do |response|
        unless response.success?
          raise SendGridResponseFailedError.new(response.body)
        end
      end
    end

    # :nodoc:
    # Used only for testing
    def params
      data = {
        "personalizations" => [personalizations],
        "subject"          => email.subject,
        "from"             => from,
        "headers"          => headers,
        "reply_to"         => reply_to_params,
        "asm"              => {"group_id" => 0, "groups_to_display" => [] of Int32},
        "mail_settings"    => {sandbox_mode: {enable: sandbox?}},
      }.compact

      if asm_data = email.asm
        data = data.merge!({"asm" => asm_data})
      else
        data.delete("asm")
      end

      if template_id = email.template_id
        data = data.merge!({"template_id" => template_id})
      else
        if content.size > 0
          data = data.merge({"content" => content})
        else
          raise SendGridInvalidTemplateError.new <<-ERROR
          Unless a valid template_id is provided, a template is required.

          Try this...

            ▸ templates html, text
            ▸ def template_id
                "d-xxxxxxxxxxxxxx"
              end

          Read more on Sending emails https://luckyframework.org/guides/emails/sending-emails-with-carbon
          ERROR
        end
      end

      data
    end

    private def reply_to_params : Hash(String, String)?
      if reply = reply_to_address
        {"email" => reply}
      end
    end

    private def reply_to_address : String?
      reply_to_header.values.first?
    end

    private def reply_to_header : Hash(String, String)
      email.headers.select do |key, _value|
        key.downcase == "reply-to"
      end
    end

    private def headers : Hash(String, String)
      email.headers.reject do |key, _value|
        key.downcase == "reply-to"
      end
    end

    # The type is left off this due to how complex
    # `dynamic_template_data` can be.
    private def personalizations
      {
        "to"                    => to_send_grid_address(email.to),
        "cc"                    => to_send_grid_address(email.cc),
        "bcc"                   => to_send_grid_address(email.bcc),
        "dynamic_template_data" => email.dynamic_template_data,
      }.compact.reject do |_key, value|
        value.empty?
      end
    end

    private def to_send_grid_address(addresses : Array(Carbon::Address)) : Array(Hash(String, String))
      addresses.map do |carbon_address|
        {
          "name"  => carbon_address.name,
          "email" => carbon_address.address,
        }.compact
      end
    end

    private def from : Hash(String, String)
      to_send_grid_address([email.from]).first
    end

    private def asm_data : Hash(String, String)?
      if asm_data = email.asm
        {"asm" => asm_data}
      end
    end

    private def content : Array(Hash(String, String))
      [
        text_content,
        html_content,
      ].compact
    end

    private def text_content : Hash(String, String)?
      body = email.text_body
      if body && !body.empty?
        {
          "type"  => "text/plain",
          "value" => body,
        }
      end
    end

    private def html_content : Hash(String, String)?
      body = email.html_body
      if body && !body.empty?
        {
          "type"  => "text/html",
          "value" => body,
        }
      end
    end

    @_client : HTTP::Client?

    private def client : HTTP::Client
      @_client ||= HTTP::Client.new(BASE_URI, port: 443, tls: true).tap do |client|
        client.before_request do |request|
          request.headers["Authorization"] = "Bearer #{api_key}"
          request.headers["Content-Type"] = "application/json"
        end
      end
    end
  end
end
