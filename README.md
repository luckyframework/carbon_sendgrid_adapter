# Carbon SendGrid Adapter

Integration for Lucky's [Carbon](https://github.com/luckyframework/carbon) email library and [SendGrid](https://sendgrid.com).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     carbon_sendgrid_adapter:
       github: luckyframework/carbon_sendgrid_adapter
   ```

2. Run `shards install`

## Usage

Create an environment variable called `SEND_GRID_KEY` with your SendGrid api key.

Update your `config/email.cr` file to use SendGrid

```crystal
require "carbon_sendgrid_adapter"

BaseEmail.configure do |settings|
 if LuckyEnv.production?
   send_grid_key = send_grid_key_from_env
   settings.adapter = Carbon::SendGridAdapter.new(api_key: send_grid_key)
 else
  settings.adapter = Carbon::DevAdapter.new
 end
end

private def send_grid_key_from_env
  ENV["SEND_GRID_KEY"]? || raise_missing_key_message
end

private def raise_missing_key_message
  puts "Missing SEND_GRID_KEY. Set the SEND_GRID_KEY env variable to 'unused' if not sending emails, or set the SEND_GRID_KEY ENV var.".colorize.red
  exit(1)
end
```

### Sending Dynamic Template emails

SendGrid allows you to use [Dynamic Transactional Templates](https://docs.sendgrid.com/ui/sending-email/how-to-send-an-email-with-dynamic-transactional-templates) when
sending your emails. These templates are designed and created inside of the
SendGrid website.

Define a `template_id`, and `dynamic_template_data` method in your
email class to use the dynamic template.

1. Login to SendGrid
2. Select Email API > Dynamic Templates
3. Create a new template
4. Copy the "Template-ID" value for that template.
5. Update your email class

```crystal
# Using built-in templates
class WelcomeEmail < BaseEmail
  def initialize(@user : User)
  end

  to @user
  subject "Welcome - Confirm Your Email"
  templates html, text
end
```

```crystal
# Using dynamic templates
class WelcomeEmail < BaseEmail
  def initialize(@user : User)
  end

  # This must be the String value of your ID
  def template_id
    "d-12345abcd6543dcbaffeedd1122aabb"
  end

  # This is optional. Define a Hash with your
  # custom handlebars variables
  def dynamic_template_data
    {
      "username" => @user.username,
      "confirmEmailUrl" => "https://myapp.com/confirm?token=..."
    }
  end

  to @user
  subject "Welcome - Confirm Your Email"
end
```

NOTE: SendGrid requires you to either define `template_id` or use the `templates` macro
to generate an email body content.

### Sending Bulk Emails

SendGrid's [Personalizations API](https://www.twilio.com/docs/sendgrid/for-developers/sending-email/personalizations) allows you to send customized emails to multiple recipients in a single API request. Each recipient can receive different content, subjects, and template data.

To use bulk email sending, define a `bulk_personalizations` method in your email class that returns an array of personalization hashes:

```crystal
class BulkPromotionEmail < BaseEmail
  def initialize(@customers : Array(Customer))
  end

  from Carbon::Address.new("promotions@myapp.com")

  # When using bulk_personalizations, the standard to/cc/bcc/subject
  # methods are not used - each personalization defines its own recipients
  to [] of Carbon::Address
  subject "Promotion" # This will be ignored

  def template_id
    "d-promotion-template-123"
  end

  def bulk_personalizations
    @customers.map do |customer|
      {
        "to" => [
          {
            "email" => customer.email,
            "name" => customer.name
          }
        ],
        "subject" => "Special Offer for #{customer.name}!",
        "dynamic_template_data" => {
          "name" => customer.name,
          "discount_code" => customer.discount_code,
          "discount_amount" => customer.discount_amount
        }
      }
    end
  end
end

# Send to multiple customers at once
BulkPromotionEmail.new(customers).deliver
```

#### Personalization Options

Each personalization hash can include:

- `"to"` (required): Array of recipient hashes with `"email"` and optional `"name"`
- `"cc"` (optional): Array of CC recipient hashes
- `"bcc"` (optional): Array of BCC recipient hashes
- `"subject"` (optional): Custom subject line for this recipient
- `"dynamic_template_data"` (optional): Template variables for this recipient
- `"send_at"` (optional): Unix timestamp for scheduled sending

**Important Notes:**
- Maximum 1,000 personalizations per API request
- Each personalization must have at least one `"to"` recipient
- When using `bulk_personalizations`, the root-level `subject` is ignored
- Works with both dynamic templates (`template_id`) and standard templates

## Contributing

1. Fork it (<https://github.com/luckyframework/carbon_sendgrid_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matthew McGarvey](https://github.com/matthewmcgarvey) - maintainer
