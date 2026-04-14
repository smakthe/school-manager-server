# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_11_100000) do
  create_table "academic_years", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.boolean "is_current", default: false, null: false
    t.string "name", null: false
    t.bigint "school_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "is_current"], name: "index_academic_years_on_school_id_and_is_current"
    t.index ["school_id", "name"], name: "index_academic_years_on_school_id_and_name", unique: true
    t.index ["school_id"], name: "index_academic_years_on_school_id"
  end

  create_table "admins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classrooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "academic_year_id", null: false
    t.bigint "class_teacher_id", null: false
    t.datetime "created_at", null: false
    t.integer "grade", null: false
    t.bigint "school_id", null: false
    t.integer "section", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_classrooms_on_academic_year_id"
    t.index ["class_teacher_id", "academic_year_id"], name: "index_classrooms_on_class_teacher_and_year", unique: true
    t.index ["school_id", "academic_year_id", "grade", "section"], name: "idx_on_school_id_academic_year_id_grade_section_d711b1049a", unique: true
    t.index ["school_id"], name: "index_classrooms_on_school_id"
  end

  create_table "enrollments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "academic_year_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_enrollments_on_academic_year_id"
    t.index ["classroom_id"], name: "index_enrollments_on_classroom_id"
    t.index ["student_id", "academic_year_id"], name: "index_enrollments_on_student_id_and_academic_year_id", unique: true
    t.index ["student_id"], name: "index_enrollments_on_student_id"
  end

  create_table "marks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.decimal "max_score", precision: 5, scale: 2, null: false
    t.decimal "score", precision: 5, scale: 2, null: false
    t.bigint "subject_id", null: false
    t.integer "term", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "subject_id", "term"], name: "index_marks_on_enrollment_subject_term", unique: true
    t.index ["enrollment_id"], name: "index_marks_on_enrollment_id"
    t.index ["subject_id"], name: "index_marks_on_subject_id"
  end

  create_table "schools", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.integer "board", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "subdomain", null: false
    t.integer "subscription_status", default: 0, null: false
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_schools_on_subdomain", unique: true
  end

  create_table "students", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "admission_number", null: false
    t.datetime "created_at", null: false
    t.date "dob", null: false
    t.integer "gender", null: false
    t.string "name", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "admission_number"], name: "index_students_on_school_id_and_admission_number", unique: true
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  create_table "subjects", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "grade", null: false
    t.string "name", null: false
    t.bigint "school_id", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "grade", "code"], name: "index_subjects_on_school_id_and_grade_and_code", unique: true
    t.index ["school_id"], name: "index_subjects_on_school_id"
  end

  create_table "teacher_subject_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "academic_year_id", null: false
    t.bigint "classroom_id", null: false
    t.datetime "created_at", null: false
    t.bigint "subject_id", null: false
    t.bigint "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_teacher_subject_assignments_on_academic_year_id"
    t.index ["classroom_id", "subject_id", "academic_year_id"], name: "index_tsa_on_classroom_subject_year", unique: true
    t.index ["classroom_id"], name: "index_teacher_subject_assignments_on_classroom_id"
    t.index ["subject_id"], name: "index_teacher_subject_assignments_on_subject_id"
    t.index ["teacher_id"], name: "index_teacher_subject_assignments_on_teacher_id"
  end

  create_table "teachers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "doj", null: false
    t.string "employee_code", null: false
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.decimal "salary", precision: 10, scale: 2, null: false
    t.bigint "school_id", null: false
    t.string "type", default: "Teacher", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id", "employee_code"], name: "index_teachers_on_school_id_and_employee_code", unique: true
    t.index ["school_id"], name: "index_teachers_on_school_id"
    t.index ["type"], name: "index_teachers_on_type"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.bigint "userable_id", null: false
    t.string "userable_type", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable"
  end

  add_foreign_key "academic_years", "schools"
  add_foreign_key "classrooms", "academic_years"
  add_foreign_key "classrooms", "schools"
  add_foreign_key "classrooms", "teachers", column: "class_teacher_id"
  add_foreign_key "enrollments", "academic_years"
  add_foreign_key "enrollments", "classrooms"
  add_foreign_key "enrollments", "students"
  add_foreign_key "marks", "enrollments"
  add_foreign_key "marks", "subjects"
  add_foreign_key "students", "schools"
  add_foreign_key "subjects", "schools"
  add_foreign_key "teacher_subject_assignments", "academic_years"
  add_foreign_key "teacher_subject_assignments", "classrooms"
  add_foreign_key "teacher_subject_assignments", "subjects"
  add_foreign_key "teacher_subject_assignments", "teachers"
  add_foreign_key "teachers", "schools"
end
