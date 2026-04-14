class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action :authenticate_request
  # We removed the before_action :map_jsonapi_page_param because we are intercepting it directly below!

  attr_reader :current_user

  # --- THE ULTIMATE PAGY INTERCEPTOR ---
  def pagy(collection, vars = {})
    # Safely extract the page whether the request is ?page[number]=2 or standard ?page=2
    page_number = if params[:page].is_a?(Hash) || params[:page].is_a?(ActionController::Parameters)
                    params.dig(:page, :number)
                  else
                    params[:page]
                  end || 1

    # Force the variables into Pagy before it does its own processing
    vars[:page]  ||= page_number
    vars[:items] ||= 20 # For Pagy v5/v6 compatibility
    vars[:limit] ||= 20 # For Pagy v7/v8+ compatibility
    
    super(collection, vars)
  end
  # -------------------------------------

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