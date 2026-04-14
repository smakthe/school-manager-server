class UserSerializer
  include JSONAPI::Serializer
  attributes :email, :userable_type, :userable_id
end
