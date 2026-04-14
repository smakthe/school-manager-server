class Api::V1::Admin::TeachersController < Api::V1::Admin::BaseController
  before_action :set_teacher, only: [:show, :update, :destroy]

  def index
    scope = Teacher.all
    scope = scope.where(school_id: params[:school_id]) if params[:school_id].present?
    
    @pagy, @teachers = pagy(scope)
    render_jsonapi(TeacherSerializer, @teachers, pagy: @pagy)
  end

  def show
    render_jsonapi(TeacherSerializer, @teacher)
  end

  def create
    @teacher = Teacher.new(teacher_params)
    
    # Bind the login credentials automatically using nested payload
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
    @teacher = Teacher.find(params[:id])
  end

  def teacher_params
    params.require(:teacher).permit(:school_id, :employee_code, :name, :doj, :salary, :is_active)
  end
end
