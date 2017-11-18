class ProfessorsController < ApplicationController

  def index
    @all_profs = Professor.all_profs("EECS")
  end

  def show
    @prof = Professor.find(params[:id])
    @prof_courses = @prof.courses.order(rating: :desc)
    @uniq_prof_courses = @prof.unique_courses
    @terms_and_ratings = @prof.chart_info 
    #already ordered (term-wise) (data for graphs)
  end

  def all
    all_professor_courses = []
    Professor.all.each do |professor| 
      professor.professor_courses.each do |professor_course|
        all_professor_courses << {professor_name: professor.name, course_id: professor_course.id, number: professor_course.number, course_name: professor_course.name, rating: professor_course.rating, term: professor_course.term, professor_id: professor_course.professor_id}
      end
    end
    render :text => all_professor_courses.to_json
  end

  def distinguished
    @dist_eecs_profs = Professor.dist_profs("EECS")
    @awarded_hum_profs = Professor.awarded_hum_profs
  end
end