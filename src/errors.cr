module Carbon
  class CarbonError < Exception
  end

  # Raised if your email is missing both `template_id`
  # and `templates`.
  class SendGridInvalidTemplateError < CarbonError
  end

  # Raised if the response from SendGrid is not
  # successful
  class SendGridResponseFailedError < CarbonError
  end
end
