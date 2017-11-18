require 'csv'

class User < ActiveRecord::Base

	validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :uid, presence: true, uniqueness: true
	has_many :user_courses

	def self.all_emails
		emails = []
		self.all.each { |user| emails << user.email }
		return emails
	end

	def courses
		courses = []
		self.user_courses.each do |course|
		courses << {id: Course.find_by(number: course.number).id,
						    number: course.number, title: course.title, taken: course.taken}
		end
    Utils.alpha_sort(courses, :number)
		return courses
	end

	def has_taken(prereq)
    user_course = self.user_courses.find_by(number: prereq.number)
    lab_course = self.user_courses.find_by(number: prereq.number + "L")
    return ((user_course != nil and user_course.taken) or (lab_course != nil and lab_course.taken))
	end

  def wants_to_take(course_number)
    user_course = self.user_courses.find_by(number: course_number)
    return (user_course != nil and not user_course.taken)
  end

  def can_take(course_number, ignore_flag)
    if Course.exists?(number: course_number)
      course = Course.find_by(number: course_number)
      if has_taken(course)
        return false
      end
      if ignore_flag
        return true
      end
      course.prereqs.each do |prereq|
        if not has_taken(prereq)
          return false
        end
      end
      return true
    else
      return false
    end
  end

  def added_courses
    return self.courses.select { |course| not course[:taken] }
  end

  def taken_courses
    return self.courses.select { |course| course[:taken] }
  end

  def recommended_EECS_courses(ignore_flag)
    draft_schedule = Utils.draft_schedule

    semesters = {fall: {courses: {}, possible_courses: [], backup_courses: []}, spring: {courses: {}, possible_courses: [], backup_courses: []}}

    semesters.each do |name, semester|
      semester[:courses] = draft_schedule[name]
      semester[:courses].each_key do |course_number|
        if self.wants_to_take(course_number) and self.can_take(course_number, ignore_flag)
          semester[:possible_courses] << course_number
        elsif self.can_take(course_number, ignore_flag)
          semester[:backup_courses] << course_number
        end
      end
      get_course_data(semester[:possible_courses], semester[:courses])
      get_course_data(semester[:backup_courses], semester[:courses])
      
      # for filtering out "Best Alternative Courses" who's ratings are lower than "Courses You're Interested In"
      # the overall rating for the professors teaching a course is stored in the [2] index of a course;
      if not semester[:possible_courses].blank?
        min_interested_rating = semester[:possible_courses].min_by {|x| x[2].to_f}[2].to_f
        semester[:backup_courses] = semester[:backup_courses].select{|a| a[2].to_f > min_interested_rating}
      end
    end
    
    return { possible_fall: semesters[:fall][:possible_courses],
             backup_fall: semesters[:fall][:backup_courses],
             possible_spring: semesters[:spring][:possible_courses],
             backup_spring: semesters[:spring][:backup_courses] }
  end

  def recommended_breadth_courses
    fall_breadth_courses = Utils.breadth_schedule
    distinguished_fall_breadth_courses = []
    fall_breadth_courses.each do |course|
      professor = Professor.find_by(name: course[2])
      if professor and professor.distinguished
        distinguished_fall_breadth_courses << course
      end
    end

    return distinguished_fall_breadth_courses
  end

  protected
  def get_average_rating_of_professors(professors)
    total = 0
    num_professors = 0
    professors.each do |name|
      if name == "TBA"
        next
      end
      professor = Professor.find_by(name: name)
      if professor
        if professor.rating and professor.rating != "*"
          total += professor.rating
          num_professors += 1
        end
      end
    end
    return num_professors > 0 ? (total / num_professors).round(2) : "*"
  end

  def get_course_data(course_list, term_list)
    course_list.map! { |course_number| [Course.find_by(number: course_number),
              term_list[course_number].split(";"),
              get_average_rating_of_professors(term_list[course_number].split(";"))] }
    course_list.each do |data|
      new_professors = []
      data[1].each do |professor_name|
        new_professors << Professor.find_by(name: professor_name)
      end
      data[1] = new_professors
    end

    course_list.sort_by! do |data|
      if data[2] == "*"
        0
      else
        -data[2]
      end
    end
  end
end
