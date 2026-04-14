class Api::V1::Principal::TeachersController < Api::V1::Principal::BaseController
  before_action :set_teacher, only: [:show, :update, :destroy]

  def index
    @pagy, @teachers = pagy(current_school.teachers)
    render_jsonapi(TeacherSerializer, @teachers, pagy: @pagy)
  end

  def show
    render_jsonapi(TeacherSerializer, @teacher)
  end

  def create
    @teacher = current_school.teachers.build(teacher_params)
    
    if params.dig(:teacher, :user, :email).present? && params.dig(:teacher, :user, :password).present?
      @teacher.build_user(
        email: params[:teacher][:user][:email],
        password: params[:teacher][:user][:password]
      )
    end

    if @teacher.save
      render json: TeacherSerializer.new(@teacher).serializable_hash, status: :created
    else
      render_errors(@teacher)
    end
  end

  def update
    if @teacher.update(teacher_params)
      render_jsonapi(TeacherSerializer, @teacher)
    else
      render_errors(@teacher)
    end
  end

  def destroy
    @teacher.destroy
    head :no_content
  end

  private

  def set_teacher
    @teacher = current_school.teachers.find(params[:id])
  end

  def teacher_params
    # Notice we permit :type to allow an admin/principal to create another principal if they want.
    params.require(:teacher).permit(:employee_code, :name, :doj, :salary, :is_active, :type)
  end
end
