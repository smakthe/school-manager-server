require 'faker'
require 'ruby-progressbar'
require 'bcrypt'
require 'set'

# Suppress SQL noise — without this, printing millions of queries freezes the terminal.
ActiveRecord::Base.logger = nil

puts "Cleaning Database..."
[User, Mark, Enrollment, TeacherSubjectAssignment, Classroom, Subject, Student, Teacher, AcademicYear, School, Admin].each(&:delete_all)

puts "Creating Superadmin..."
Admin.create!
User.create!(
  userable: Admin.first,
  email:    ENV['SUPERADMIN_EMAIL']    || 'admin@school.com',
  password: ENV['SUPERADMIN_PASSWORD'] || 'password'
)

puts "Pre-computing BCrypt hashes for bulk insertion..."
hashed_password = BCrypt::Password.create('1234', cost: 4).to_s

TOTAL_SCHOOLS = 1000
CLASS_GRADES  = (1..10).to_a
SECTIONS      = [0, 1, 2]   # 0=A, 1=B, 2=C
TERMS         = [0, 1, 2]   # confirm matches your Term enum
MAX_SCORE     = 100.0

SUBJECTS_LIST = [
  { code: 'MAT', name: 'Mathematics' },       { code: 'ENG', name: 'English' },
  { code: 'HIN', name: 'Hindi' },             { code: 'SST', name: 'Social Studies' },
  { code: 'SAN', name: 'Sanskrit' },          { code: 'COM', name: 'Commerce' },
  { code: 'ECO', name: 'Economics' },         { code: 'BST', name: 'Business Studies' },
  { code: 'ACC', name: 'Accountancy' },       { code: 'HIS', name: 'History' },
  { code: 'GEO', name: 'Geography' },         { code: 'PHY', name: 'Physics' },
  { code: 'CHE', name: 'Chemistry' },         { code: 'BIO', name: 'Biology' },
  { code: 'BOT', name: 'Botany' },            { code: 'ZOO', name: 'Zoology' },
  { code: 'CMP', name: 'Computer Science' },  { code: 'CRA', name: 'Craft' },
  { code: 'POL', name: 'Political Science' }, { code: 'PSY', name: 'Psychology' },
  { code: 'EVS', name: 'Environmental Science' }
].freeze

@used_subdomains = Set.new

def generate_unique_school
  name = subdomain = ""
  attempts = 0
  
  loop do
    pattern = rand(1..4)
    name = case pattern
           when 1 then "#{Faker::Address.city} #{%w[International Global Royal Modern].sample} Academy"
           when 2 then "#{Faker::Name.last_name} #{%w[Memorial Heritage Pioneer].sample} Institute"
           when 3 then "#{Faker::Space.star} #{%w[Valley Summit Horizon Heights].sample} School"
           when 4 then "The #{Faker::Address.state} School of Excellence"
           end

    # Fallback: If Faker happens to generate the exact same name multiple times,
    # append a clean, realistic identifier instead of a random hex code.
    name = "#{name} (Campus #{attempts})" if attempts > 5

    # Increased from 15 to 35 characters. This prevents subdomain collisions 
    # for cities with long names while keeping URLs clean.
    subdomain = name.parameterize.gsub('-', '')[0..35]

    unless @used_subdomains.include?(subdomain)
      @used_subdomains.add(subdomain)
      break
    end
    
    attempts += 1
  end
  
  [name, subdomain]
end

puts "Starting Strict Sequential Bulk Insert. No threads, no deadlocks."
progressbar = ProgressBar.create(
  title:  "Schools",
  total:  TOTAL_SCHOOLS,
  format: '%t: |%B| %p%% %e'
)

# TRUE SEQUENTIAL LOOP - No Parallel block
1.upto(TOTAL_SCHOOLS) do |_school_index|
  now = Time.now.utc

  # ─── 1. SCHOOL & ACADEMIC YEAR ────────────────────────────────────────────
  school_name, subdomain = generate_unique_school
  
  school = School.create!(
    name:                school_name,
    subdomain:           subdomain,
    board:               rand(0..2),
    subscription_status: 1,
    address:             Faker::Address.full_address,
    phone:               Faker::PhoneNumber.phone_number,
    timezone:            "Asia/Kolkata"
  )
  domain = "#{school.subdomain}.edu.co"

  academic_year = AcademicYear.create!(
    school_id:  school.id,
    name:       "2026-2027",
    start_date: Date.new(2026, 4, 1),
    end_date:   Date.new(2027, 3, 31),
    is_current: true
  )

  # ─── 2. SUBJECTS ──────────────────────────────────────────────────────────
  subjects_batch = CLASS_GRADES.flat_map do |grade|
    SUBJECTS_LIST.map do |subj|
      { school_id: school.id, code: subj[:code], name: subj[:name], grade: grade, created_at: now, updated_at: now }
    end
  end
  Subject.insert_all!(subjects_batch)
  subjects_by_grade = Subject.where(school_id: school.id).to_a.group_by(&:grade)

  # ─── 3. STAFF ─────────────────────────────────────────────────────────────
  principal = Principal.create!(
    school_id:     school.id,
    name:          Faker::Name.name,
    employee_code: "PR-#{school.id}-1",
    doj:           Faker::Date.backward(days: 3650),
    salary:        100_000.0,
    is_active:     true
  )

  teachers_batch = []
  30.times { |i| teachers_batch << { school_id: school.id, name: Faker::Name.name, employee_code: "TCH-#{school.id}-C#{i}", doj: Faker::Date.backward(days: 1000), salary: 50_000.0, is_active: true, type: 'Teacher', created_at: now, updated_at: now } }
  15.times { |i| teachers_batch << { school_id: school.id, name: Faker::Name.name, employee_code: "TCH-#{school.id}-E#{i}", doj: Faker::Date.backward(days: 1000), salary: 40_000.0, is_active: true, type: 'Teacher', created_at: now, updated_at: now } }
  Teacher.insert_all!(teachers_batch)

  all_teachers   = Teacher.where(school_id: school.id, type: 'Teacher').to_a
  class_teachers = all_teachers.select { |t| t.employee_code.start_with?("TCH-#{school.id}-C") }
  extra_teachers = all_teachers.select { |t| t.employee_code.start_with?("TCH-#{school.id}-E") }

  # ─── 4. USERS ─────────────────────────────────────────────────────────────
  users_batch = [{
    userable_type:   'Principal',
    userable_id:     principal.id,
    email:           "principal@#{domain}",
    password_digest: hashed_password,
    created_at:      now,
    updated_at:      now
  }]
  
  all_teachers.each do |t|
    users_batch << {
      userable_type:   'Teacher',
      userable_id:     t.id,
      email:           "#{t.employee_code.downcase}@#{domain}",
      password_digest: hashed_password,
      created_at:      now,
      updated_at:      now
    }
  end
  User.insert_all!(users_batch)

  # ─── 5. CLASSROOMS ────────────────────────────────────────────────────────
  classrooms_batch = []
  CLASS_GRADES.each_with_index do |grade, g_idx|
    SECTIONS.each_with_index do |sec, s_idx|
      t_idx = (g_idx * SECTIONS.size) + s_idx
      classrooms_batch << {
        school_id:        school.id,
        academic_year_id: academic_year.id,
        class_teacher_id: class_teachers[t_idx].id,
        grade:            grade,
        section:          sec,
        created_at:       now,
        updated_at:       now
      }
    end
  end
  Classroom.insert_all!(classrooms_batch)
  classrooms = Classroom.where(school_id: school.id).to_a

  # ─── 6. STUDENTS ──────────────────────────────────────────────────────────
  students_batch = []
  classrooms.each do |classroom|
    age = classroom.grade + 5
    rand(25..35).times do |s_idx|
      students_batch << {
        school_id:        school.id,
        name:             Faker::Name.name,
        admission_number: "ADM-#{school.id}-#{classroom.id}-#{s_idx}",
        dob:              Faker::Date.birthday(min_age: age - 1, max_age: age + 1),
        gender:           rand(0..2),
        created_at:       now,
        updated_at:       now
      }
    end
  end
  Student.insert_all!(students_batch)

  admission_numbers = students_batch.map { |s| s[:admission_number] }
  inserted_students = Student.where(admission_number: admission_numbers)
                             .select(:id, :admission_number)
                             .to_a

  # ─── 7. ENROLLMENTS ───────────────────────────────────────────────────────
  enrollments_batch = inserted_students.map do |student|
    classroom_id = student.admission_number.split('-')[2].to_i
    {
      student_id:       student.id,
      classroom_id:     classroom_id,
      academic_year_id: academic_year.id,
      status:           0,
      created_at:       now,
      updated_at:       now
    }
  end
  Enrollment.insert_all!(enrollments_batch)

  inserted_enrollments = Enrollment
    .where(academic_year_id: academic_year.id, classroom_id: classrooms.map(&:id))
    .select(:id, :classroom_id)
    .to_a
    .group_by(&:classroom_id)

  # ─── 8. TEACHER SUBJECT ASSIGNMENTS ──────────────────────────────────────
  tsa_batch = []
  classrooms.each do |classroom|
    grade_subjects = subjects_by_grade[classroom.grade] || []
    shuffled_extras = extra_teachers.shuffle

    grade_subjects.each_with_index do |subj, idx|
      tsa_batch << {
        teacher_id:       shuffled_extras[idx % shuffled_extras.length].id,
        classroom_id:     classroom.id,
        subject_id:       subj.id,
        academic_year_id: academic_year.id,
        created_at:       now,
        updated_at:       now
      }
    end
  end
  TeacherSubjectAssignment.insert_all!(tsa_batch)

  # ─── 9. MARKS ─────────────────────────────────────────────────────────────
  marks_batch = []
  classrooms.each do |classroom|
    grade_subjects       = subjects_by_grade[classroom.grade] || []
    enrollments_in_class = inserted_enrollments[classroom.id] || []

    enrollments_in_class.each do |enrollment|
      grade_subjects.each do |subj|
        TERMS.each do |term|
          marks_batch << {
            enrollment_id: enrollment.id,
            subject_id:    subj.id,
            term:          term,
            score:         rand(0.0..MAX_SCORE).round(2),
            max_score:     MAX_SCORE,
            created_at:    now,
            updated_at:    now
          }
        end
      end
    end
  end

  # Chunked to stay under MySQL's max_allowed_packet limit.
  marks_batch.each_slice(10_000) { |chunk| Mark.insert_all!(chunk) }

  # Safely increment the progress bar directly
  progressbar.increment
end

puts "\nAll Seed scripts completed successfully!"