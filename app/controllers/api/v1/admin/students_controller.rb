class Api::V1::Admin::StudentsController < Api::V1::Admin::BaseController
  before_action :set_student, only: [:show, :update, :destroy]

  def index
    scope = Student.all
    if params[:school_id].present?
      scope = scope.where(school_id: params[:school_id])
    end
    if params[:classroom_id].present?
      scope = scope.joins(:enrollments).where(enrollments: { classroom_id: params[:classroom_id] })
    end
    @pagy, @students = pagy(scope, items: 100)
    render_jsonapi(StudentSerializer, @students, pagy: @pagy)
  end

  def show
    render_jsonapi(StudentSerializer, @student)
  end

  def create
    @student = Student.new(student_params)
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
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:school_id, :name, :admission_number, :dob, :gender, :is_active)
  end
end
