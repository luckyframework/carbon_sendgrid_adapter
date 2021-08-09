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
   settings.adapter = construct_send_grid_adapter
 else
  settings.adapter = Carbon::DevAdapter.new
 end
end

private def construct_send_grid_adapter
  if ENV["SEND_GRID_KEY"]?
    Carbon::SendGridAdapter.new(api_key: ENV["SEND_GRID_KEY"])
  elsif ENV["SENDGRID_USER"]? && ENV["SENDGRID_PASSWORD"]?
    Carbon::SendGridAdapter.new(username: ENV["SENDGRID_USER"], password: ENV["SENDGRID_PASSWORD"])
  else
    raise_missing_key_message
  end
end

private def raise_missing_key_message
  puts "Missing SEND_GRID_KEY. Set the SEND_GRID_KEY env variable to 'unused' if not sending emails, or set the SEND_GRID_KEY ENV var.".colorize.red
  exit(1)
end
```

## Contributing

1. Fork it (<https://github.com/your-github-user/carbon_sendgrid_adapter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matthew McGarvey](https://github.com/matthewmcgarvey) - maintainer
