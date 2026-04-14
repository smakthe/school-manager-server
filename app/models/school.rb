class School < ApplicationRecord
  has_many :academic_years, dependent: :destroy
  has_many :classrooms, dependent: :destroy
  has_many :teachers, dependent: :destroy
  has_many :students, dependent: :destroy
  has_many :subjects, dependent: :destroy

  enum :board, {
    cbse:  0,
    icse:  1,
    state: 2,
    ib:    3
  }

  enum :subscription_status, {
    trial:     0,
    active:    1,
    suspended: 2,
    cancelled: 3
  }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates :board, presence: true
  validates :subscription_status, presence: true
end