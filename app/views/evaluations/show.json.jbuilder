json.extract! @evaluation, :id, :evaluationable_id, :evaluationable_type, :desc,
  :good, :delivery, :customer_service, :user_id, :order_id, :title, :avatar_urls, 
  :image_urls, :cover_urls
json.user_nickname @evaluation.user.nickname
json.user_avatar @evaluation.user.avatar_url