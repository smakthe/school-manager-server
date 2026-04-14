class Api::V1::Principal::BaseController < ApplicationController
  include RoleAuthorizable

  require_role :Principal
end
