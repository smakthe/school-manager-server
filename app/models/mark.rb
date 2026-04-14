class Mark < ApplicationRecord
  belongs_to :enrollment
  belongs_to :subject

  enum :term, { term1: 0, term2: 1, term3: 2 }

  validates :term, presence: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :max_score, presence: true, numericality: { greater_than: 0 }
  validates :subject_id, uniqueness: {
    scope: [:enrollment_id, :term],
    message: "already has a mark recorded for this term and enrollment"
  }
  validate :score_cannot_exceed_max_score

  # Delegates for convenience in serializers and views
  delegate :student, to: :enrollment, allow_nil: true
  delegate :name, to: :subject, prefix: true, allow_nil: true
  delegate :grade, to: :subject, prefix: true, allow_nil: true

  def percentage
    return 0 if max_score.zero?
    ((score / max_score) * 100).round(2)
  end

  private

  def score_cannot_exceed_max_score
    return unless score && max_score
    errors.add(:score, "cannot exceed max score") if score > max_score
  end
end