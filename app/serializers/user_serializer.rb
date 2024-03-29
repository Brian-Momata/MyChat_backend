class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :username, :avatar
end
