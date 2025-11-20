# https://docs.sendgrid.com/ui/sending-email/how-to-send-an-email-with-dynamic-transactional-templates
module Carbon::SendGridExtensions
  # Define the dynamic template_id to use
  # when sending an email. This will be a
  # String value of the template defined
  # in SendGrid. If `nil`, then use the
  # Carbon template system.
  def template_id
    nil
  end

  # Define the dynamic data to be replaced
  # in your email template. This should be a
  # dynamic Hash(String, Any) where the keys
  # must match with your template values.
  # If `nil`, then no data is sent.
  def dynamic_template_data
    nil
  end

  # Define the group ids to determine how to
  # handle unsubscribes.
  # https://docs.sendgrid.com/ui/sending-email/unsubscribe-groups
  def asm
    nil
  end

  # Define bulk personalizations for sending multiple
  # customized emails in a single API request.
  # This enables SendGrid's bulk email functionality.
  # https://www.twilio.com/docs/sendgrid/for-developers/sending-email/personalizations
  #
  # Return an Array of Hashes where each Hash represents
  # a personalization with the following keys:
  #   - "to" (required): Array of recipient hashes with "email" and optional "name"
  #   - "cc" (optional): Array of CC recipient hashes
  #   - "bcc" (optional): Array of BCC recipient hashes
  #   - "subject" (optional): Custom subject for this personalization
  #   - "dynamic_template_data" (optional): Template variables for this recipient
  #   - "send_at" (optional): Unix timestamp for scheduled sending
  #
  # Example:
  #   def bulk_personalizations
  #     [
  #       {
  #         "to" => [{"email" => "user1@example.com", "name" => "User 1"}],
  #         "subject" => "Hello User 1",
  #         "dynamic_template_data" => {"name" => "User 1", "discount" => "10%"}
  #       },
  #       {
  #         "to" => [{"email" => "user2@example.com", "name" => "User 2"}],
  #         "subject" => "Hello User 2",
  #         "dynamic_template_data" => {"name" => "User 2", "discount" => "20%"}
  #       }
  #     ]
  #   end
  #
  # Note: Maximum 1,000 personalizations per API request
  def bulk_personalizations
    nil
  end
end

alias AttachFile = NamedTuple(file_path: String, file_name: String, mime_type: String)
alias ResourceFile = NamedTuple(file_path: String, file_name: String, mime_type: String)
alias AttachIO = NamedTuple(io: IO, file_name: String, mime_type: String)
alias ResourceIO = NamedTuple(io: IO, file_name: String, mime_type: String)

class Carbon::Email
  include Carbon::SendGridExtensions

  def attachments
    [] of AttachFile | ResourceFile | AttachIO | ResourceIO
  end

  macro attachment(method_name)
    def attachments
      {% if @type.methods.map(&.name).includes?(:attachments.id) %}
        previous_def
      {% end %}
      [{{ method_name.id }}]
    end
  end
end
