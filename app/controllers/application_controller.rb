class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JwtService.decode(token)

    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    end

    unless @current_user
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def current_userable
    current_user&.userable
  end

  def render_jsonapi(serializer_class, resource, options = {})
    if options[:pagy]
      options[:meta] ||= {}
      options[:meta].merge!(pagy_metadata(options[:pagy]))
    end
    render json: serializer_class.new(resource, options).serializable_hash
  end

  def render_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
