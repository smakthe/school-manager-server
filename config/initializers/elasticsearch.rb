Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: "http://#{ENV.fetch('ELASTICSEARCH_HOST', '127.0.0.1')}:9200",
  retry_on_failure: 5,
  request_timeout: 30
)
