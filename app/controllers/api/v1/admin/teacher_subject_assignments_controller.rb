class Api::V1::Admin::TeacherSubjectAssignmentsController < Api::V1::Admin::BaseController
  before_action :set_assignment, only: [:destroy]

  def index
    if params[:classroom_id].present?
      scope = TeacherSubjectAssignment.includes(:teacher, :subject).where(classroom_id: params[:classroom_id])
    elsif params[:teacher_id].present?
      scope = TeacherSubjectAssignment.includes(:classroom, :subject).where(teacher_id: params[:teacher_id])
    else
      return render json: { error: 'classroom_id or teacher_id parameter is required' }, status: :bad_request
    end
    
    @pagy, @assignments = pagy(scope)
    render_jsonapi(TeacherSubjectAssignmentSerializer, @assignments, pagy: @pagy)
  end

  def create
    @assignment = TeacherSubjectAssignment.new(assignment_params)
    
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