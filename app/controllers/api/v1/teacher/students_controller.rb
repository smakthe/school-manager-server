class Api::V1::Teacher::StudentsController < Api::V1::Teacher::BaseController
  before_action :set_student, only: [:show, :update]

  def index
    @pagy, @students = pagy(current_school.students)
    render_jsonapi(StudentSerializer, @students, pagy: @pagy)
  end

  def show
    render_jsonapi(StudentSerializer, @student)
  end

  def update
    unless current_userable.homeroom_students.exists?(id: @student.id)
      return render json: { error: 'Forbidden: You can only update students within your homeroom class.' }, status: :forbidden
    end

    if @student.update(student_params)
      render_jsonapi(StudentSerializer, @student)
    else
      render_errors(@student)
    end
  end

  private

  def set_student
    @student = current_school.students.find(params[:id])
  end

  def student_params
    # Restrict what a teacher can edit (e.g. they shouldn't edit admission numbers)
    params.require(:student).permit(:name, :dob, :gender, :is_active)
  end
end
