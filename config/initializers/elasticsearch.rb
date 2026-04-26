# frozen_string_literal: true

require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: "http://elastic:#{ENV.fetch('ELASTICSEARCH_PASSWORD')}@localhost:9200",
  log: Rails.env.development?
)
