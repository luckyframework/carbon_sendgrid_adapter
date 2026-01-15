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

  # Define categories for your email to organize
  # and track analytics by category.
  # https://docs.sendgrid.com/ui/analytics-and-reporting/categories
  def categories : Array(String)?
    nil
  end

  # Define a unix timestamp to schedule when
  # the email should be sent.
  # https://docs.sendgrid.com/ui/sending-email/scheduling-parameters
  def send_at : Int64?
    nil
  end
end

class Carbon::Email
  include Carbon::SendGridExtensions
end
