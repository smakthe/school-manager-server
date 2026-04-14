class Subject < ApplicationRecord
  include Schoolable

  has_many :teacher_subject_assignments, dependent: :destroy
  has_many :teachers, through: :teacher_subject_assignments
  has_many :classrooms, through: :teacher_subject_assignments
  has_many :marks, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: { scope: [:school_id, :grade] }
  validates :grade, presence: true, inclusion: { in: 1..10 }
end