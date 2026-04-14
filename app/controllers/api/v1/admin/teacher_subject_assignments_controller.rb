class Api::V1::Admin::TeacherSubjectAssignmentsController < Api::V1::Admin::BaseController
  before_action :set_assignment, only: [:destroy]

  def index
    unless params[:classroom_id].present?
      return render json: { error: 'classroom_id parameter is required' }, status: :bad_request
    end

    scope = TeacherSubjectAssignment.includes(:teacher, :subject).where(classroom_id: params[:classroom_id])
    
    @pagy, @assignments = pagy(scope)
    render_jsonapi(TeacherSubjectAssignmentSerializer, @assignments, pagy: @pagy)
  end

  def create
    @assignment = TeacherSubjectAssignment.new(assignment_params)
    
    # Automatically inherit the academic year from the classroom if not explicitly passed
    @assignment.academic_year_id ||= @assignment.classroom&.academic_year_id

    if @assignment.save
      render json: TeacherSubjectAssignmentSerializer.new(@assignment).serializable_hash, status: :created
    else
      render_errors(@assignment)
    end
  end

  def destroy
    @assignment.destroy
    head :no_content
  end

  private

  def set_assignment
    @assignment = TeacherSubjectAssignment.find(params[:id])
  end

  def assignment_params
    params.require(:teacher_subject_assignment).permit(:teacher_id, :classroom_id, :subject_id, :academic_year_id)
  end
end