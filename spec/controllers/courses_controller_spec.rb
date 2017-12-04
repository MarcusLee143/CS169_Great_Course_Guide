require "spec_helper"
require "rails_helper"
require "json"

describe CoursesController do

  User.destroy_all
  Professor.destroy_all
  Course.destroy_all

  CASClient::Frameworks::Rails::Filter.fake("123456")

  describe "Getting a specific class" do
    before :each do
      User.destroy_all
      Course.destroy_all
      @user = User.create(first_name: "Test", last_name: "Test", uid: "123456", email: "Test@test.test")
      @course = Course.create(number: "CS61A", title: "SICP")
    end
    it "should assign the correct course to @course" do
      get :show, id: @course.id
      expect(assigns(:course)).to eq(@course)
    end
    it "should assign @prereqs" do
      get :show, id: @course.id
      expect(assigns(:prereqs).nil?).to eq(@course.compute_prereqs_given_user(@user)[0].empty?)
    end
    it "should load the schedule page" do
      get :schedule
      expect(response).to render_template :schedule
    end
  end
  
  describe "Showing better alternative classes" do
    before :each do
      User.destroy_all
      Course.destroy_all
      Professor.destroy_all
      UserCourse.destroy_all
      ProfessorCourse.destroy_all
      @test_user = User.create(first_name: "Test", last_name: "Test", uid: "123456", email: "Test@test.test")
      @a = Course.create(number: "A", title: "TestA")
      @b = Course.create(number: "B", title: "TestB")
      @c = Course.create(number: "C", title: "TestC")
      @prof1 = Professor.create(name: "Prof1")
      @prof2 = Professor.create(name: "Prof2")
      @prof3 = Professor.create(name: "Prof3")
      @prof1.courses.create(number: "A", name: "TestA", rating: 4.0, term: "SP16")
      @prof2.courses.create(number: "B", name: "TestB", rating: 3.0, term: "SP16")
      @prof3.courses.create(number: "C", name: "TestC", rating: 7.0, term: "SP16")
      @test_user.user_courses.create(number: "A", title: "TestA", taken: false)
      # @user.user_courses.create(number: "B", title: "TestB", taken: false)
      # @user.user_courses.create(number: "C", title: "TestC", taken: false)
      @draft_course_a = @a.draft_courses.create(professor: "Prof1", term: "FA16")
      @draft_course_b = @b.draft_courses.create(professor: "Prof2", term: "FA16")
      @draft_course_c = @c.draft_courses.create(professor: "Prof3", term: "FA16")
      get :schedule
    end
    it "should load the schedule page" do
      expect(response).to render_template :schedule
    end
    it "should have the correct rating threshold" do
      expect(assigns(:recommended_EECS_courses)[:possible_fall].min_by {|x| x[2]}[2][0]).to eq(4.0)
    end
    it "should contain correct number of suggested courses" do
      expect(assigns(:fall_length)).to eq(2)
    end
  end

  describe 'Querying filter REST endpoint' do
    before :each do
      BtFilter.destroy_all
      @default_filter = BtFilter.create(filter: 'default', category: 'default', filter_id: '1,2,3,4')
      @filter1 = BtFilter.create(filter: 'Filter1', category: 'Category1', filter_id: '1')
      @filter2 = BtFilter.create(filter: 'Filter2', category: 'Category1', filter_id: '2')
      @filter3 = BtFilter.create(filter: 'Filter3', category: 'Category2', filter_id: '3')
      @expected_default = {
          'filter' => 'default',
          'category' => 'default',
          'filter_id' => '1,2,3,4'
      }
      @expected1 = {
          'filter' => 'Filter1',
          'category' => 'Category1',
          'filter_id' => '1'
      }
      @expected2 = {
          'filter' => 'Filter2',
          'category' => 'Category1',
          'filter_id' => '2'
      }
      @expected3 = {
          'filter' => 'Filter3',
          'category' => 'Category2',
          'filter_id' => '3'
      }
    end
    it 'should load the correct number of filters for one category with multiple filters' do
      get :filter, {:category => 'Category1'}
      tmp = JSON.parse(response.body.to_s)
      expect(tmp).to include(@expected_default)
      expect(tmp).to include(@expected1)
      expect(tmp).to include(@expected2)
    end
    it 'should load the correct number of filters for one category with one filter' do
      get :filter, {:category => 'Category2'}
      tmp = JSON.parse(response.body.to_s)
      expect(tmp).to include(@expected_default)
      expect(tmp).to include(@expected3)
    end
    it 'should call filter category function if given a category query parameter' do
      expect(controller).to receive(:filter_category).with('Category1')
      get :filter, {:category => 'Category1'}
    end
    it 'should call filter filter function if given a filter query parameter' do
      expect(controller).to receive(:filter_filter).with('Filter1')
      get :filter, {:filter => 'Filter1'}
    end
  end

end
