class AcademicYearSerializer
  include JSONAPI::Serializer
  attributes :name, :start_date, :end_date, :is_current, :school_id
end
