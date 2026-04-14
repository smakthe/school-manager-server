class Api::V1::Admin::AcademicYearsController < Api::V1::Admin::BaseController
  before_action :set_academic_year, only: [:show, :update, :destroy]

  def index
    @pagy, @academic_years = pagy(AcademicYear.all)
    render_jsonapi(AcademicYearSerializer, @academic_years, pagy: @pagy)
  end

  def show
    render_jsonapi(AcademicYearSerializer, @academic_year)
  end

  def create
    academic_year = AcademicYear.new(academic_year_params)
    if academic_year.save
      render json: AcademicYearSerializer.new(academic_year).serializable_hash, status: :created
    else
      render_errors(academic_year)
    end
  end

  def update
    if @academic_year.update(academic_year_params)
      render_jsonapi(AcademicYearSerializer, @academic_year)
    else
      render_errors(@academic_year)
    end
  end

  def destroy
    @academic_year.destroy
    head :no_content
  end

  private

  def set_academic_year
    @academic_year = AcademicYear.find(params[:id])
  end

  def academic_year_params
    params.require(:academic_year).permit(:name, :start_date, :end_date, :is_current, :school_id)
  end
end
