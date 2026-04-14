class AcademicYear < ApplicationRecord
  include Schoolable

  has_many :classrooms, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :teacher_subject_assignments, dependent: :destroy

  scope :current, -> { where(is_current: true) }

  validates :name, presence: true, uniqueness: { scope: :school_id }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :is_current, uniqueness: {
    scope: :school_id,
    if: :is_current?,
    message: "academic year already exists for this school"
  }

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, "must be after the start date") if end_date <= start_date
  end
end