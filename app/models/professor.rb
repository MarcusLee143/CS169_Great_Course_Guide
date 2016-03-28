class Professor < ActiveRecord::Base
    has_many :professor_courses
    validates_uniqueness_of :name

   	def courses
   		self.professor_courses
   	end

    def rating
        courses = self.professor_courses
        rating_sum = courses.sum(:rating)
        num_courses = courses.length
        avg_rating = 0
        if num_courses > 0
            avg_rating = (rating_sum/courses.length).round(2)
        end
        return avg_rating if not avg_rating.nan? else 0
    end

	def self.all_profs
		profs = []
		self.all.each do |prof|
      rating = prof.rating
			profs << {name: prof.name, rating: prof.rating}
		end
		profs = profs.sort_by { |professor| -professor[:rating] }
		return profs
	end

  def self.dist_profs
    dist_profs = []
    self.all.each do |prof|
      if prof.distinguished
        dist_profs << {name: prof.name, rating: prof.rating}
      end
    end
    dist_profs = dist_profs.sort_by { |professor| -professor[:rating] }
    return dist_profs
  end
end
