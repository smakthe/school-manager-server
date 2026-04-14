class Api::V1::Admin::ClassroomsController < Api::V1::Admin::BaseController
  before_action :set_classroom, only: [:show, :update, :destroy]

  def index
    scope = Classroom.all
    scope = scope.where(school_id: params[:school_id]) if params[:school_id].present?
    
    @pagy, @classrooms = pagy(scope)
    render_jsonapi(ClassroomSerializer, @classrooms, pagy: @pagy)
  end

  def show
    render_jsonapi(ClassroomSerializer, @classroom)
  end

  def create
    @classroom = Classroom.new(classroom_params)
    if @classroom.save
      render json: ClassroomSerializer.new(@classroom).serializable_hash, status: :created
    else
      render_errors(@classroom)
    end
  end

  def update
    if @classroom.update(classroom_params)
      render_jsonapi(ClassroomSerializer, @classroom)
    else
      render_errors(@classroom)
    end
  end

  def destroy
    @classroom.destroy
    head :no_content
  end

  private

  def set_classroom
    @classroom = Classroom.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:school_id, :academic_year_id, :class_teacher_id, :grade, :section)
  end
end
