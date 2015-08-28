json.(@attachment,  *@attachment.attributes.keys)
json.success true
json.html render partial: "admins/subjects/attachment", object: @attachment, formats: [ :html ]

