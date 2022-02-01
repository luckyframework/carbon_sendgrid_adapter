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
end

class Carbon::Email
  include Carbon::SendGridExtensions
end
