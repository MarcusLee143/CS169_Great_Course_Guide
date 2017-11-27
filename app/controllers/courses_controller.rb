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
    resp = []
    if params[:category]
      tmp = BtFilter.where(category: params[:category])
      if tmp.length > 0
        filters = tmp
      end
    elsif params[:filter]
      tmp = BtFilter.where(filter: params[:filter])
      if tmp.length > 0
        filters = tmp
      end
    end
    if filters
      default_filter = BtFilter.where(filter: 'default')[0]
      default_filter = {
          :filter => default_filter.filter,
          :category => default_filter.category,
          :filter_id => default_filter.filter_id
      }
      resp << default_filter
      filters.each do |filter|
        tmp = {:filter => filter.filter, :category => filter.category, :filter_id => filter.filter_id}
        resp << tmp
      end
    end
    render :json => resp
  end
end

