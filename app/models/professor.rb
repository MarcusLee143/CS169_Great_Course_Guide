class Professor < ActiveRecord::Base
  has_many :professor_courses
  has_many :awards
  validates_uniqueness_of :name

  def courses
    return self.professor_courses
  end

  def unique_courses
    courses = self.courses.select(:name, :number).uniq.sort_by { |p_course| -self.rating_for(p_course.number) }
    #courses = ProfessorCourse.where(professor_id: self.id).select(:name, :number).uniq.sort_by { |p_course| -self.rating_for(p_course.number) }
    return courses
  end

  def rating
    rating_sum = self.courses.sum(:rating)
    num_courses = self.courses.length
    return num_courses == 0 ? "*" : (rating_sum / num_courses).round(2)
  end

  def rating_for(course_number)
    total = 0
    self.professor_courses.where(number: course_number).each do |professor_course|
      total += professor_course.rating
    end
    return (total / self.professor_courses.where(number: course_number).length).round(2)
  end

	def self.all_profs(type)
		profs = []
		self.where(category: type).each do |prof|
      if not prof.name == "TBA"
			  profs << {id: prof.id, name: prof.name, rating: prof.rating}
      end
		end
    profs.sort_by do |prof|
      if prof[:rating] == "*"
        0.0
      else
        -prof[:rating]
      end
    end
	end


  def self.dist_profs(type)
    dist_profs = []
    self.where(category: type).each do |prof|
      if prof.distinguished
        dist_profs << prof
      end
    end
    dist_profs.sort_by do |prof|
      if prof.rating == "*"
        0.0
      else
        -prof.rating
      end
    end
  end

  def chart_info
    terms = []
    ratings = []
    self.courses.each do |p_course|
      terms << p_course.number + " " + p_course.term
      ratings << p_course.rating
    end
    return terms,ratings
  end

  def all_awards
    awards = ""
    self.awards.each do |award|
      if award == self.awards.last
        awards << "#{award.year} #{award.title}"
      else
        awards << "#{award.year} #{award.title}, "
      end
    end
    return awards
  end

  def self.awarded_hum_profs
    return self.where(category: "HUM", awarded: true)
  end
end
