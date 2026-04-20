class Classroom < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "school_manager_classrooms_#{Rails.env}"

  include Schoolable
  belongs_to :academic_year
  belongs_to :class_teacher, class_name: "Teacher", foreign_key: :class_teacher_id, inverse_of: :homeroom

  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments
  has_many :teacher_subject_assignments, dependent: :destroy
  has_many :subject_teachers, through: :teacher_subject_assignments, source: :teacher
  has_many :subjects, through: :teacher_subject_assignments
  has_many :marks, through: :enrollments

  enum :section, { a: 0, b: 1, c: 2 }

  validates :grade, presence: true, inclusion: { in: 1..10 }
  validates :section, presence: true
  validates :class_teacher, presence: true
  validates :class_teacher_id, uniqueness: {
    scope: :academic_year_id,
    message: "is already a class teacher for another classroom in this academic year"
  }
  validates :grade, uniqueness: {
    scope: [:school_id, :academic_year_id, :section],
    message: "already has a classroom for this section and academic year"
  }

  ROMAN = %w[_ I II III IV V VI VII VIII IX X].freeze

  # Returns "IV-C", "IX-A", "VIII-B" etc.
  def display_name
    "#{grade_in_roman}-#{section.upcase}"
  end

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :grade, :section, :school_id, :academic_year_id]
    ).merge(
      school_name: school.name,
      display_name: display_name,
      class_teacher_name: class_teacher&.name,
      document_type: 'classroom'
    )
  end

  def grade_in_roman
    ROMAN[grade]
  end
end