class Api::V1::Admin::SchoolsController < Api::V1::Admin::BaseController
  before_action :set_school, only: [:show, :update, :destroy]

  def index
    scope = School.all
    if params[:board].present?
      requested_boards = params[:board].split(',')
      valid_boards = requested_boards.select { |b| School.boards.keys.include?(b) }
      
      if valid_boards.any?
        scope = scope.where(board: valid_boards)
      else
        scope = scope.none
      end
    end
    @pagy, @schools = pagy(scope)
    render_jsonapi(SchoolSerializer, @schools, pagy: @pagy)
  end

  def board_stats
    stats = {}
    School.boards.keys.each do |board|
      schools_ids = School.where(board: board).select(:id)
      stats[board] = {
        schools: schools_ids.count,
        teachers: Teacher.where(school_id: schools_ids).count,
        students: Student.where(school_id: schools_ids).count
      }
    end
    render json: stats
  end

  def show
    render_jsonapi(SchoolSerializer, @school)
  end

  def create
    school = School.new(school_params)
    if school.save
      render json: SchoolSerializer.new(school).serializable_hash, status: :created
    else
      render_errors(school)
    end
  end

  def update
    if @school.update(school_params)
      render_jsonapi(SchoolSerializer, @school)
    else
      render_errors(@school)
    end
  end

  def destroy
    @school.destroy
    head :no_content
  end

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(:name, :subdomain, :board, :phone, :address, :timezone, :subscription_status)
  end
end
