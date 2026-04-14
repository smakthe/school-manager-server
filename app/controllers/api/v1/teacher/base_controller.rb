class Api::V1::Teacher::BaseController < ApplicationController
  include RoleAuthorizable

  require_role :Teacher
end
