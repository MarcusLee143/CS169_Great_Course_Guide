require 'set'

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  # Filter Needed for CalNet Login
  before_filter CASClient::Frameworks::Rails::Filter
  before_action :require_info, :except => [:welcome, :all, :emails, :create, :verify, :filter]
  before_action :get_info, :except => :create

  def require_info
    user_exists = User.find_by(uid: session[:cas_user]) != nil
    if not user_exists
      redirect_to "/welcome" and return
    end
  end

  def get_info
    @user = User.find_by(uid: session[:cas_user])
    @user_exists = @user != nil
    @all_courses = Course.all_courses
    @all_emails = User.all_emails
    @filter_map = Course.filter
    session[:return_to] = request.referer
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
    session.clear and return
  end

  # Displays a page to allow the user to enter information
  def welcome
    redirect_to "/user" and return if @user_exists
    render "welcome", layout: false and return
  end

  def index
  end

  def about
    render "about"
  end

  def edit
    @user_classNames = []
    @user_takenClassNames = []
    @user.user_courses.each do |course|
      if course.taken
        @user_takenClassNames << course.number
      end
      @user_classNames << course.number
    end
  end

  def update
    @user.user_courses.destroy_all
    taken_classes = params[:taken_classes]
    if params[:classes] != nil
      params[:classes].each_key do |course|
        attrs = Utils.split_by_colon(course)
        begin
          taken = taken_classes.include?(course)
        rescue
          taken = false
        end
        @user.user_courses.create(title: attrs[0], number: attrs[1], taken: taken)
      end
    end

    redirect_to "/user" and return
  end

  def create
    @user = User.create(first_name: params[:first_name],
                        last_name: params[:last_name], email: params[:email],
                                                        uid: session[:cas_user])
    if not @user.valid?
      @user = User.find_by(uid: session[:cas_user])
    end

    if params[:class_select] != nil
      params[:class_select].each do |course|
        attrs = Utils.split_by_colon(course)
        if @user.user_courses.find_by(title: attrs[0]).nil?
          @user.user_courses.create(title: attrs[0], number: attrs[1], taken: true)
        end
      end
    end

    redirect_to "/user" and return
  end

  def verify
    if @all_emails.include?(params[:email])
      resp = {:resp => false}
    else
      resp = {:resp => true}
    end
    render :json => resp
  end

  def updateFilters
    session[:filter_settings] = params[:filter_settings]
    puts session[:filter_settings]
    render :text => "null"
  end

end
