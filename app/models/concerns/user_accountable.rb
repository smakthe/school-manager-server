module UserAccountable
  extend ActiveSupport::Concern

  included do
    has_one :user, as: :userable, dependent: :destroy
  end
end
