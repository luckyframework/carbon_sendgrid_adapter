class BulkEmail < Carbon::Email
  def initialize(
    @from = Carbon::Address.new("from@example.com"),
    @users : Array(NamedTuple(email: String, name: String, discount: String)) = [] of NamedTuple(email: String, name: String, discount: String)
  )
  end

  from @from
  subject "Bulk Email" # This will be overridden by personalization subjects
  to [] of Carbon::Address # Not used in bulk mode

  def template_id
    "d-bulk-template-123"
  end

  def bulk_personalizations
    @users.map do |user|
      {
        "to"                    => [{"email" => user[:email], "name" => user[:name]}],
        "subject"               => "Hello #{user[:name]}!",
        "dynamic_template_data" => {
          "name"     => user[:name],
          "discount" => user[:discount],
        },
      }
    end
  end
end
