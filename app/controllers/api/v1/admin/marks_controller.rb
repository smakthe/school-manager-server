class Api::V1::Admin::MarksController < Api::V1::Admin::BaseController
  def index
    unless params[:student_id].present?
      return render json: { error: 'student_id parameter is required' }, status: :bad_request
    end

    # Fetch all marks for the student through their enrollments
    scope = Mark.joins(:enrollment).where(enrollments: { student_id: params[:student_id] })
    
    @pagy, @marks = pagy(scope)
    render_jsonapi(MarkSerializer, @marks, pagy: @pagy)
  end
end