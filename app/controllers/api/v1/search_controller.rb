module Api
  module V1
    class SearchController < ApplicationController
      def index
        query_string = params[:q].to_s.strip
        if query_string.blank?
          render json: { data: [] }
          return
        end

        must_clauses = [
          {
            multi_match: {
              query: query_string,
              fields: ['*'],
              type: 'cross_fields',
              operator: 'and'
            }
          }
        ]

        filter_clauses = []
        models_to_search = [School, Classroom, Teacher, Student]

        case @current_user.userable_type
        when 'Principal'
          school_id = @current_user.userable.school_id
          filter_clauses << { term: { school_id: school_id } }
          models_to_search = [Classroom, Teacher, Student]
        when 'Teacher'
          teacher = @current_user.userable
          school_id = teacher.school_id
          
          allowed_classroom_ids = teacher.teacher_subject_assignments.pluck(:classroom_id)
          allowed_classroom_ids << teacher.homeroom&.id if teacher.homeroom
          allowed_classroom_ids.compact!.uniq!

          filter_clauses << { term: { school_id: school_id } }
          
          filter_clauses << {
            bool: {
              should: [
                {
                  bool: {
                    must: [
                      { term: { document_type: 'classroom' } },
                      { terms: { _id: allowed_classroom_ids.map(&:to_s) } }
                    ]
                  }
                },
                {
                  bool: {
                    must: [
                      { term: { document_type: 'student' } },
                      { terms: { classroom_id: allowed_classroom_ids } }
                    ]
                  }
                }
              ],
              minimum_should_match: 1
            }
          }
          
          models_to_search = [Classroom, Student]
        end

        search_definition = {
          query: {
            bool: {
              must: must_clauses,
              filter: filter_clauses
            }
          },
          size: 50
        }

        records = Elasticsearch::Model.search(search_definition, models_to_search).records.to_a

        serialized_data = records.map do |record|
          hash = case record
                 when School
                   SchoolSerializer.new(record).serializable_hash[:data]
                 when Classroom
                   ClassroomSerializer.new(record).serializable_hash[:data]
                 when Teacher
                   TeacherSerializer.new(record).serializable_hash[:data]
                 when Student
                   StudentSerializer.new(record).serializable_hash[:data]
                 else
                   nil
                 end
          hash
        end.compact

        render json: { data: serialized_data }
      rescue StandardError => e
        render json: { data: [], error: e.message }, status: :internal_server_error
      end
    end
  end
end
