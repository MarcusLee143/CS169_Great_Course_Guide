require 'csv'
require 'set'
require 'json'

Professor.destroy_all
ProfessorCourse.destroy_all
Course.destroy_all
Award.destroy_all
DraftCourse.destroy_all
BtFilter.destroy_all

distinguishedProfs = Hash.new
CSV.foreach('data/awards.csv') do |line|
  name = line[0]
  year = line[1]
  award_title = line[2]
  if award_title =~ /Distinguished Teaching Award/
    distinguishedProfs[name] = year
  end
end

CSV.foreach('data/classNames.csv', converters: :numeric) do |line|
  number = line[0]
  title = line[1]
  Course.create(number: number, title: title)
end

CSV.foreach('data/classPrereqs.csv') do |line|
  size = line.size()
  number = line[0]
  course = Course.find_by_number(number)
  line[1..size].each do |prereq|
    course.prereqs.create(number: prereq)
  end
end

CSV.foreach('data/classData.csv', converters: :numeric) do |row|
  name = row[1] + " " + row[0] # John Denero
  number = row[2].split(' ', 2)[0] # CS61A
  term = row[2].split(' ', 2)[1] # Fall 2015

  # Calculate the rating
  total = row[4] + row[5] + row[6] + row[7] + row[8] + row[9] + row[10]
  if term =~ /Spring 2011/ or term =~ /Summer 2010/
    avg = (row[4]*7 + row[5]*6 + row[6]*5 + row[7]*4 + row[8]*3 + row[9]*2 + row[10]*1).to_f
  else
    avg = (row[4]*1 + row[5]*2 + row[6]*3 + row[7]*4 + row[8]*5 + row[9]*6 + row[10]*7).to_f
  end
  rating = total == 0 ? 0 : (avg/total).round(2) # Rating

  professor = Professor.find_by(name: name)
  if professor.nil?
    professor = Professor.create(name: name)
    if distinguishedProfs.keys.include?(name)
      professor.distinguished = true
      professor.awarded = true
      professor.distinguishedYear = distinguishedProfs[name]
      professor.save
    end
  end

  course = Course.find_by(number: number)
  courseName = course.title
  professor.courses.create(number: number, rating: rating, term: term, name: courseName)
end

distinguishedProfs.each do |name, year|
  prof = Professor.find_by(name: name)
  if prof.nil?
    professor = Professor.create(name: name, distinguished: true,
      distinguishedYear: year, category: "HUM", awarded: true)
  end
end

# New Professors for the year
Professor.create(name: "TBA")
Professor.create(name: "Ken Goldberg")
Professor.create(name: "Nicholas Weaver")
Professor.create(name: "Joseph Gonzalez")
Professor.create(name: "Alexandra von Meier")

CSV.foreach('data/awards.csv') do |line|
  name = line[0]
  year = line[1]
  award_title = line[2]
  prof = Professor.find_by(name: name)
  if prof
    prof.awards.create(title: award_title, year: year)
  else
    prof = Professor.create(name: name, category: "HUM", awarded: true)
    prof.awards.create(title: award_title, year: year)
  end
end

CSV.foreach('data/DraftSchedule.csv') do |line|
  course = Course.find_by(number: line[0])
  if not line[1].nil?
    course.draft_courses.create(term: "FA16", professor: line[1])
  end
  if line.length == 3
    course.draft_courses.create(term: "SP17", professor: line[2])
  end
end

newest_run = 'data/run_2017-11-03_17_33_48/bt_filter.json'
filter_data_hash = JSON.parse(File.read(newest_run))
filter_data_hash.each do |key, hash|
  BtFilter.create(filter: key, category: hash['category'], filter_id: hash['id'])
end