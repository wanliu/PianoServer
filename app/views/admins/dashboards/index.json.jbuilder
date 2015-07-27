json.array!(@admin_dashboards) do |admin_dashboard|
  json.extract! admin_dashboard, :id
  json.url admin_dashboard_url(admin_dashboard, format: :json)
end
