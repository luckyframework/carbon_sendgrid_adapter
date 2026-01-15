class EmailWithSendGridFeatures < Carbon::Email
  getter text_body, html_body

  def initialize(
    @from = Carbon::Address.new("from@example.com"),
    @to = [] of Carbon::Address,
    @cc = [] of Carbon::Address,
    @bcc = [] of Carbon::Address,
    @headers = {} of String => String,
    @subject = "subject",
    @text_body : String? = nil,
    @html_body : String? = nil,
  )
  end

  def template_id
    "d-1234567890"
  end

  def dynamic_template_data
    {
      "name" => "Test User",
    }
  end

  def categories : Array(String)
    ["welcome", "onboarding", "transactional"]
  end

  def send_at : Int64
    1704067200_i64 # 2024-01-01 00:00:00 UTC
  end

  from @from
  to @to
  cc @cc
  bcc @bcc
  subject @subject
end
