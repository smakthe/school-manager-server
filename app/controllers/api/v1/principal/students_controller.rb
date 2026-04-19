class Api::V1::Principal::StudentsController < Api::V1::Principal::BaseController
  before_action :set_student, only: [:show, :update, :destroy]

  def index
    scope = current_school.students
    if params[:classroom_id].present?
      scope = scope.joins(:enrollments).where(enrollments: { classroom_id: params[:classroom_id] })
    end
    @pagy, @students = pagy(scope)
    render_jsonapi(StudentSerializer, @students, pagy: @pagy)
  end

  def show
    render_jsonapi(StudentSerializer, @student)
  end

  def create
    @student = current_school.students.build(student_params)
    if @student.save
      render json: StudentSerializer.new(@student).serializable_hash, status: :created
    else
      render_errors(@student)
    end
  end

  def update
    if @student.update(student_params)
      render_jsonapi(StudentSerializer, @student)
    else
      render_errors(@student)
    end
  end

  def destroy
    @student.destroy
    head :no_content
  end

  private

  def set_student
    @student = current_school.students.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:name, :admission_number, :dob, :gender, :is_active)
  end
end
