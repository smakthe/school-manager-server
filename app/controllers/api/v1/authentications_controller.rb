class Api::V1::AuthenticationsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create], raise: false

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)

      render json: {
        token: token,
        user: {
          id: user.id,
          email: user.email,
          role: user.userable_type.downcase,
          userable_id: user.userable_id
        }
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
