class Api::V1::Teacher::ClassroomsController < Api::V1::Teacher::BaseController
  before_action :set_classroom, only: [:show]

  def index
    @pagy, @classrooms = pagy(current_school.classrooms)
    render_jsonapi(ClassroomSerializer, @classrooms, pagy: @pagy)
  end

  def show
    render_jsonapi(ClassroomSerializer, @classroom)
  end

  private

  def set_classroom
    @classroom = current_school.classrooms.find(params[:id])
  end
end
