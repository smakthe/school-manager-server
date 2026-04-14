class Enrollment < ApplicationRecord
  belongs_to :student
  belongs_to :classroom
  belongs_to :academic_year

  has_many :marks, dependent: :destroy

  enum :status, { active: 0, transferred: 1, graduated: 2 }

  validates :student_id, uniqueness: {
    scope: :academic_year_id,
    message: "is already enrolled in a classroom for this academic year"
  }
  validates :status, presence: true

  # Delegate frequently accessed fields to avoid extra joins in views/serializers
  delegate :name, to: :student, prefix: false, allow_nil: true
  delegate :school, to: :classroom, prefix: false, allow_nil: true
  delegate :display_name, to: :classroom, prefix: :classroom, allow_nil: true
end