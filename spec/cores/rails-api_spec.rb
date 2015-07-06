describe "RailsApi config" do 
  it "api-only" do 
    expect(Rails.application.config.api_only).to be(false)
  end
end
