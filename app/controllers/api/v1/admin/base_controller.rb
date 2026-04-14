class Api::V1::Admin::BaseController < ApplicationController
  include RoleAuthorizable

  require_role :Admin
end
