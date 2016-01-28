json.extract! @evaluation, :id, :evaluationable_id, :evaluationable_type, :desc,
  :good, :delivery, :customer_service, :user_id, :order_id, :title, :avatar_urls, 
  :image_urls, :cover_urls
json.user_nickname @evaluation.user.nickname
json.user_avatar @evaluation.user.avatar_url

if @evaluation.evaluationable_type == "PmoItem"
  json.pmo_item_id @evaluation.evaluationable_id
end

json.thumbers_count @thumbers_count
json.thumbers @thumbers do |thumber|
  json.nickname thumber.nickname
  json.avatar thumber.avatar_url
end