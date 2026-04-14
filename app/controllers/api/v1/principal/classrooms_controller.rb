class Api::V1::Principal::ClassroomsController < Api::V1::Principal::BaseController
  before_action :set_classroom, only: [:show, :update, :destroy]

  def index
    @pagy, @classrooms = pagy(current_school.classrooms)
    render_jsonapi(ClassroomSerializer, @classrooms, pagy: @pagy)
  end

  def show
    render_jsonapi(ClassroomSerializer, @classroom)
  end

  def create
    @classroom = current_school.classrooms.build(classroom_params)
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
    @classroom = current_school.classrooms.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:academic_year_id, :class_teacher_id, :grade, :section)
  end
end
