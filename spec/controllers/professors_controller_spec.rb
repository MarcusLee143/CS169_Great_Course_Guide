require "spec_helper"
require "rails_helper"

describe ProfessorsController do

  User.destroy_all
  Professor.destroy_all
  Course.destroy_all

  CASClient::Frameworks::Rails::Filter.fake("123456")
  
  describe "Getting all professors" do
    before :each do
			Professor.destroy_all
			@professor1 = Professor.create(name: "John Denero", distinguished: true, distinguishedYear: "2016", category: "EECS")
			@professor2 = Professor.create(name: "Josh Hug", category: "EECS")
			@professor3 = Professor.create(name: "Bleh", category: "EECS", distinguished: true, distinguishedYear: "2017")

			@course1 = ProfessorCourse.create(number: "CS61A", name: "Test Title 1", rating: 5.0, term: "Fall 2016")
			@course2 = ProfessorCourse.create(number: "CS61B", name: "Test Title 2", rating: 3.0, term: "Spring 2016")
			@course3 = ProfessorCourse.create(number: "CS61C", name: "Test Title 3", rating: 2.0, term: "Fall 2016")
			@course4 = ProfessorCourse.create(number: "CS61D", name: "Test Title 4", rating: 4.0, term: "Spring 2016")
			@course5 = ProfessorCourse.create(number: "CS61E", name: "Nah", rating: "*", term: "Spring 2017")

			@professor1.professor_courses << @course1
			@professor1.professor_courses << @course2
			@professor2.professor_courses << @course3
			@professor2.professor_courses << @course4
			@professor3.professor_courses << @course5
		end
    it "gets all professors and their courses" do
      get 'all', :format => :json
      data = JSON.parse(response.body)
      expect(data.length).to equal(5)
    end
  end 
end
