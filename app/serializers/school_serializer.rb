class SchoolSerializer
  include JSONAPI::Serializer
  attributes :name, :subdomain, :board, :phone, :address, :timezone, :subscription_status
end
