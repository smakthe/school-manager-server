class Teacher < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "school_manager_teachers_#{Rails.env}"

  include Schoolable

  has_many :teacher_subject_assignments, dependent: :destroy
  has_many :classrooms, through: :teacher_subject_assignments  # all classes they teach as subject teacher
  has_many :subjects, through: :teacher_subject_assignments

  include UserAccountable

  # Class teacher responsibility — a teacher is class teacher of at most
  # one classroom per academic year (enforced by a unique DB index on
  # [:class_teacher_id, :academic_year_id] and a model validation on Classroom).
  has_one :homeroom, ->(t) {
    joins(:academic_year).where(academic_years: { is_current: true, school_id: t.school_id })
  }, class_name: "Classroom", foreign_key: :class_teacher_id, inverse_of: :class_teacher

  has_many :homeroom_students, through: :homeroom, source: :students

  validates :name, presence: true
  validates :employee_code, presence: true, uniqueness: { scope: :school_id }
  validates :salary, presence: true, numericality: { greater_than: 0 }
  validates :doj, presence: true

  # Returns "IV-C", "IX-A" etc. for the teacher's current homeroom
  def homeroom_display
    homeroom&.display_name
  end

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :name, :employee_code, :type, :school_id]
    ).merge(
      school_name: school.name,
      email: user&.email,
      document_type: type.downcase # 'teacher' or 'principal'
    )
  end
end