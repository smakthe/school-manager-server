module RoleAuthorizable
  extend ActiveSupport::Concern

  class_methods do
    def require_role(role_name)
      before_action do
        unless current_userable.is_a?(role_name.to_s.constantize)
          render json: { error: "Forbidden: #{role_name} access required" }, status: :forbidden
        end
      end
    end
  end

  def current_school
    current_userable.school if current_userable.respond_to?(:school)
  end
end
