class Student < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "school_manager_students_#{Rails.env}"

  include Schoolable

  has_one :user, as: :userable, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :classrooms, through: :enrollments
  has_many :academic_years, through: :enrollments
  has_many :marks, through: :enrollments

  has_one :current_enrollment, -> {
    joins(:academic_year).where(academic_years: { is_current: true })
  }, class_name: "Enrollment", inverse_of: :student

  has_one :current_classroom, through: :current_enrollment, source: :classroom
  has_one :current_class_teacher, through: :current_classroom, source: :class_teacher

  enum :gender, {
    male: 0,
    female: 1,
    other: 2
  }

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :name, :admission_number, :gender, :school_id, :is_active]
    ).merge(
      school_name: school.name,
      classroom_id: current_classroom&.id,
      classroom_name: current_classroom&.display_name,
      email: user&.email,
      document_type: 'student'
    )
  end

  validates :name, presence: true
  validates :dob, presence: true
  validates :gender, presence: true
  validates :admission_number, presence: true, uniqueness: { scope: :school_id }

  # Returns "VII-B", "IX-A" etc. for the student's current classroom
  def current_class_display
    current_classroom&.display_name
  end

  def is_active
    current_enrollment&.active? || false
  end
end