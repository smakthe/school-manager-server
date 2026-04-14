class Api::V1::Admin::SchoolsController < Api::V1::Admin::BaseController
  before_action :set_school, only: [:show, :update, :destroy]

  def index
    @pagy, @schools = pagy(School.all)
    render_jsonapi(SchoolSerializer, @schools, pagy: @pagy)
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
