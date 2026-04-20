# frozen_string_literal: true

require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV.fetch('ELASTICSEARCH_URL', 'http://elastic:YFBJQlLY@localhost:9200'),
  log: Rails.env.development?
)
