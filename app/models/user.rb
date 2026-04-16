class User < ApplicationRecord
  has_secure_password

  belongs_to :userable, polymorphic: true

  validates :email, presence: true, uniqueness: true
  validate :email_domain_must_match_role

  private

  def email_domain_must_match_role
    return if email.blank? || userable.nil?

    if userable_type == 'Admin'
      unless email == ENV['SUPERADMIN_EMAIL']
        errors.add(:email, 'must be the authorized superadmin email')
      end
    elsif userable_type == 'Teacher' || userable_type == 'Principal'
      expected_domain = "#{userable.school.subdomain}.co.edu"
      unless email.ends_with?("@#{expected_domain}")
        errors.add(:email, "must be a valid school domain (@#{expected_domain})")
      end
    end
  end
end
