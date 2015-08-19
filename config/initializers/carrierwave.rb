CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "nbafeifeixu"
  config.upyun_password = 'wocaonimade1'
  config.upyun_bucket = "wanliu-piano"
  # upyun_bucket_domain 以后将会弃用，请改用 upyun_bucket_host
  # config.upyun_bucket_domain = "my_bucket.files.example.com"
  config.upyun_bucket_host = "http://wanliu-piano.b0.upaiyun.com"
end
