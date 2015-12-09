json.status @job.status

if @job.status == "done"
  json.html render "#{controller_name}/#{@user_type}/products_group", locals: { products_group: @job.output["products_group"] }, formats: [:html]
end
