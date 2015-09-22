Elasticsearch::Model.client = Elasticsearch::Client.new url: Settings.elasticsearch.url, log: true
