json.status @job.status

if @job.status == "done"
  json.html render "#{controller_name}/#{@user_type}/welcome", locals: {job: @job, shop: @shop }, formats: [:html]
end
