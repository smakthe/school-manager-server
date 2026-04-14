require 'faker'
require 'parallel'
require 'ruby-progressbar'
require 'bcrypt'

puts "Cleaning Database..."
[User, Mark, Enrollment, TeacherSubjectAssignment, Classroom, Subject, Student, Teacher, AcademicYear, School, Admin].each(&:delete_all)

puts "Creating Superadmin (scmakra99@gmail.com)..."
Admin.create!
User.create!(
  userable: Admin.first,
  email: 'scmakra99@gmail.com',
  password: '1234'
)

# Precompute the hash to save massive amounts of CPU cycles globally across 45,000+ users!
puts "Pre-computing BCrypt hashes for bulk insertion..."
hashed_password = BCrypt::Password.create('1234', cost: 4).to_s

TOTAL_SCHOOLS = 1000
CLASS_GRADES = (1..10).to_a
SECTIONS = [0, 1, 2] # 0=A, 1=B, 2=C
SUBJECTS_LIST = [
  { code: 'MAT', name: 'Mathematics' },
  { code: 'ENG',  name: 'English' },
  { code: 'HIN', name: 'Hindi' },
  { code: 'SST', name: 'Social Studies' },
  { code: 'SAN', name: 'Sanskrit' },
  { code: 'COM', name: 'Commerce' },
  { code: 'ECO', name: 'Economics' },
  { code: 'BST', name: 'Business Studies' },
  { code: 'ACC', name: 'Accountancy' },
  { code: 'HIS',  name: 'History' },
  { code: 'GEO',  name: 'Geography' },
  { code: 'PHY',  name: 'Physics' },
  { code: 'CHE',  name: 'Chemistry' },
  { code: 'BIO',  name: 'Biology' },
  { code: 'BOT', name: 'Botany' },
  { code: 'ZOO', name: 'Zoology' },
  { code: 'CMP',  name: 'Computer Science' },
  { code: 'CRA',  name: 'Craft' },
  { code: 'POL',  name: 'Political Science' },
  { code: 'PSY',  name: 'Psychology' },
  { code: 'EVS',  name: 'Environmental Science' }
]

puts "Spawning Fast Seed Threads. Dual-core max-throttle activated."

# Ruby-progressbar is thread safe and will accurately represent progression.
progressbar = ProgressBar.create(title: "Schools", total: TOTAL_SCHOOLS, format: '%t: |%B| %p%% %e')

Parallel.each(1..TOTAL_SCHOOLS, in_threads: 2) do |school_index|
  ActiveRecord::Base.connection_pool.with_connection do
    
    # 1. GENERATE SCHOOL
    school_name = Faker::University.name + " " + SecureRandom.hex(2)
    subdomain = school_name.parameterize.gsub('-', '')[0..15] + SecureRandom.hex(2)
    school = School.create!(
      name: school_name,
      subdomain: subdomain,
      board: rand(0..2),
      subscription_status: 1
    )
    domain = "#{school.subdomain}.co.edu"

    # 2. GENERATE ACADEMIC YEAR
    academic_year = AcademicYear.create!(
      school_id: school.id,
      name: "2026-2027",
      start_date: Date.new(2026, 4, 1),
      end_date: Date.new(2027, 3, 31),
      is_current: true
    )

    # 3. GENERATE SUBJECTS (per grade level)
    school_subjects = []
    CLASS_GRADES.each do |grade|
      SUBJECTS_LIST.each do |subj|
        school_subjects << Subject.create!(school_id: school.id, code: subj[:code], name: subj[:name], grade: grade)
      end
    end

    # 4. GENERATE STAFF 
    users_to_insert = []
    
    # --> Principal
    principal = Principal.create!(
      school_id: school.id,
      name: Faker::Name.name,
      employee_code: "PR-#{school.id}-1",
      doj: Faker::Date.backward(days: 3650),
      salary: 100000.0,
      is_active: true
    )
    users_to_insert << {
      userable_type: 'Teacher',
      userable_id: principal.id,
      email: "#{Faker::Internet.username(specifier: principal.name, separators: %w(.))}#{principal.id}@#{domain}",
      password_digest: hashed_password,
      created_at: Time.now.utc,
      updated_at: Time.now.utc
    }
    
    # --> Exactly 30 Class Teachers
    class_teachers = []
    30.times do |i|
      class_teachers << Teacher.create!(
        school_id: school.id,
        name: Faker::Name.name,
        employee_code: "TCH-#{school.id}-C#{i}",
        doj: Faker::Date.backward(days: 1000),
        salary: 50000.0,
        is_active: true
      )
    end
    
    # --> Extra Teachers (10 to 20 floating subject teachers)
    extra_teachers = []
    rand(9..19).times do |i|
      extra_teachers << Teacher.create!(
        school_id: school.id,
        name: Faker::Name.name,
        employee_code: "TCH-#{school.id}-E#{i}",
        doj: Faker::Date.backward(days: 1000),
        salary: 40000.0,
        is_active: true
      )
    end
    
    # Bind User hashes for all 40-50 regular teachers
    (class_teachers + extra_teachers).each do |t|
      users_to_insert << {
        userable_type: 'Teacher',
        userable_id: t.id,
        email: "#{Faker::Internet.username(specifier: t.name, separators: %w(.))}#{t.id}@#{domain}",
        password_digest: hashed_password,
        created_at: Time.now.utc,
        updated_at: Time.now.utc
      }
    end

    # Bulk insert all user credentials bypassing 45,000 slow ActiveRecord triggers
    User.insert_all!(users_to_insert)


    # 5. GENERATE CLASSROOMS, STUDENTS, AND ASSIGNMENTS
    classroom_count = 0

    CLASS_GRADES.each do |grade|
      SECTIONS.each do |sec|
        assigned_teacher = class_teachers[classroom_count]
        classroom = Classroom.create!(
          school_id: school.id,
          academic_year_id: academic_year.id,
          class_teacher_id: assigned_teacher.id,
          grade: grade,
          section: sec
        )
        classroom_count += 1

        # --> Students Bulk Data Prep (30 to 50 per class)
        num_students = rand(30..50)
        chunked_students = []
        
        num_students.times do |s_idx|
          chunked_students << {
            school_id: school.id,
            name: Faker::Name.name,
            admission_number: "ADM-#{school.id}-#{classroom.id}-#{s_idx}-#{SecureRandom.hex(2)}",
            dob: Faker::Date.birthday(min_age: 5, max_age: 18),
            gender: rand(0..2),
            created_at: Time.now.utc,
            updated_at: Time.now.utc
          }
        end
        Student.insert_all!(chunked_students)
        
        # --> We pull the exactly generated students back for mapping their enrollment
        student_records = Student.where(school_id: school.id).order(id: :desc).limit(num_students).pluck(:id)
        
        enrollments = student_records.map do |sid|
          {
            student_id: sid,
            classroom_id: classroom.id,
            academic_year_id: academic_year.id,
            status: 0,
            created_at: Time.now.utc,
            updated_at: Time.now.utc
          }
        end
        Enrollment.insert_all!(enrollments)

        # --> Teacher Subject Assignments dynamically distributed to non-homeroom floaters!
        # Grab exactly 3 distinct extra teachers to fill out assignment logic.
        sampled_teachers = extra_teachers.sample(3)
        available_subjects = school_subjects.select { |s| s.grade == grade }
        
        if available_subjects.any?
          sampled_teachers.each_with_index do |t, idx|
            subj = available_subjects[idx % available_subjects.length]
            TeacherSubjectAssignment.create!(
              teacher_id: t.id,
              classroom_id: classroom.id,
              subject_id: subj.id,
              academic_year_id: academic_year.id
            )
          end
        end

      end
    end

  end
  # Thread finishes chunk process
  progressbar.increment
end

puts "All Seed scripts generated seamlessly!"
