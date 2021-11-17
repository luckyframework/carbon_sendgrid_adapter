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

## Contributing

1. Fork it (<https://github.com/luckyframework/carbon_sendgrid_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matthew McGarvey](https://github.com/matthewmcgarvey) - maintainer
