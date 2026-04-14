module Schoolable
  extend ActiveSupport::Concern

  included do
    belongs_to :school
  end
end
