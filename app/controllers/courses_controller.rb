class CoursesController < ApplicationController

  def index
    if not session[:filter_settings]
      @filter_settings = {ee: true, cs: true, lower: true, upper: true, grad: true}
    else
      @filter_settings = session[:filter_settings]
    end
  end

  def show
    @course = Course.find(params[:id])
    all_prereqs = @course.compute_prereqs_given_user(@user)
    @remaining_prereqs = all_prereqs[0]
    @finished_prereqs = all_prereqs[1]

    @professorCourses = ProfessorCourse.where(number: @course.number)
    @professors = Set.new
    @professorCourses.each do |professorCourse|
      @professors << professorCourse.professor
    end
    @professors = @professors.sort_by { |professor| -professor.rating}
  end

  def all
    render :text => @all_courses.to_json
  end

  def schedule
    @ignore = "not ignoring prerequisites"
    @ignore_flag = false
    ignore = params[:ignore]
    if !ignore.nil?
      @ignore = "ignoring prerequisites"
      @ignore_flag = true
    end
    @recommended_EECS_courses = @user.recommended_EECS_courses(@ignore_flag)
    @fall_length = @recommended_EECS_courses[:possible_fall].length + @recommended_EECS_courses[:backup_fall].length
    @spring_length = @recommended_EECS_courses[:possible_spring].length + @recommended_EECS_courses[:backup_spring].length
    @recommended_breadth_courses = @user.recommended_breadth_courses
    @breadth_length = @recommended_breadth_courses.length
  end

  def filter
    resp = {:filter_id => nil, :category => nil, :filter => nil}
    if params[:category]
      filters = BtFilter.where(category: params[:category])
      if !filters.nil?
        resp = filters
      end
    elsif params[:filter]
      filter = BtFilter.where(filter: params[:filter])[0]
      if !filter.nil?
        resp = {:filter_id => filter.filter_id, :category => filter.category, :filter => params[:filter]}
      end
    end
    render :json => resp
  end
end

