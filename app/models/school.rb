class School < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "school_manager_schools_#{Rails.env}"
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

  def full_address
    [address_line_1, address_line_2, city, state, zip_code].compact_blank.join(", ")
  end

  def as_indexed_json(options = {})
    as_json(
      only: [:id, :name, :subdomain, :board, :principal_name, :city, :state, :phone, :email]
    ).merge(
      document_type: 'school'
    )
  end

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates :board, presence: true
  validates :subscription_status, presence: true
end