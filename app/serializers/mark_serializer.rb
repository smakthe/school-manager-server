class MarkSerializer
  include JSONAPI::Serializer
  attributes :enrollment_id, :subject_id, :term, :score, :max_score, :percentage

  # delegates defined in the model
  attribute :subject_grade do |object|
    object.subject_grade
  end
  attribute :subject_name do |object|
    object.subject_name
  end
end
