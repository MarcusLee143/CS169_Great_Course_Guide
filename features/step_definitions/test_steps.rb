Then /there should be the button "(.*)"/ do |button|
  should have_button button
end

num_profs = 0
Given /the following professors exist/ do |prof_table|
  num_profs = 0
  prof_table.hashes.each do |prof|
    p = Professor.create(prof)
    p.courses.create({number: "Spoon", name: "Fork", rating: -num_profs, term: "FA16"})
    num_profs += 1
  end
end

Given /the following professors, without ratings, exist/ do |prof_table|
  num_profs = 0
  prof_table.hashes.each do |prof|
    p = Professor.create(prof)
  end
end

num_courses = 0
Given /the following courses exist/ do |course_table|
  num_courses = 0
  course_table.hashes.each do |course|
    c = Course.create(course)
  end
end

Given /the following courses are going to be taught/ do |draft_course_table|
  draft_course_table.hashes.each do |draft_course|
    p = Professor.find_by(name: draft_course[:professor])
    c = Course.find_by(number: draft_course[:number])
    dc = c.draft_courses.create(professor: p.name, term: draft_course[:term])
  end
end

Given /the following courses were taught/ do |professor_course_table|
  professor_course_table.hashes.each do |professor_course|
    p = Professor.find_by(name: professor_course[:professor])
    c = Course.find_by(number: professor_course[:number])
    p.courses.create({number: c.number, name: c.title, rating: professor_course[:rating], term: professor_course[:term]})
  end
end

And /professors teach the appropriate courses/ do
  cup = Professor.find_by_name("Cup")
  dog = Professor.find_by_name("Dog")
  cat = Professor.find_by_name("Cat")
  cup.courses.create({number: "CS61A", name: "ABCD", rating: 2, term: "SP14"})
  cup.courses.create({number: "CS61B", name: "EFGH", rating: 5, term: "SP14"})
  dog.courses.create({number: "CS61C", name: "IJKL", rating: 2, term: "SP14"})
  cat.courses.create({number: "CS70", name: "MNOP", rating: 2, term: "SP14"})
  cat.courses.create({number: "CS61A", name: "ABCD", rating: 3, term: "SP15"})
end

Given /the following prerequisites exist/ do |prereq_table|
  prereq_table.hashes.each do |course|
    c = Course.find_by(number: course[:course]).prereqs.create({:number => course[:number]})
  end
end

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  e1index = page.body.index(e1)
  e2index = page.body.index(e2)
  e2index.should be > e1index
end

Then /I should not see "(.*)" before "(.*)"/ do |e1, e2|
  e1index = page.body.index(e1)
  e2index = page.body.index(e2)
  e2index.should be < e1index
end

And /I login as "(.*)"/ do |name|
  fill_in("first_name", :with => name)
  fill_in("last_name", :with => "Jackson")
  fill_in("email", :with => "mjhomie@gmail.com")
  click_button("Finish", match: :first)
end

And /I should find "(.*)"/ do |id|
  find_by_id(id)
end

Given /I have "(.*)" in my classes/ do |course_name|
  click_link("Edit", match: :first)
  check(course_name)
  check("#{course_name.split("-")[0]}" + "-taken")
  find('#save').click
end

Given /I want to take "(.*)"/ do |course_name|
  click_link("Edit", match: :first)
  check(course_name)
  find('#save').click
end

Given(/^they teach the humanities classes$/) do
  cup = Professor.find_by_name("Junko Habu")
  dog = Professor.find_by_name("Xin Liu")
  cat = Professor.find_by_name("Fae M. Ng")
  cup.courses.create({name: "Art", number: "ANTHROC125A", rating: 2, term: "FA16"})
  dog.courses.create({name: "Music", number: "ANTHRO189", rating: 2, term: "FA16"})
  cat.courses.create({name: "History", number: "ASAMST172", rating: 3, term: "FA16"})
end

Given(/^"([^"]*)" isn't teaching "([^"]*)" next semester$/) do |prof, course|
  prof = Professor.find_by_name(prof)
  prof.courses.destroy_all
  prof.distinguished = false
  prof.save
end

Then /I logout/ do
  visit('/logout')
end

Then(/^"([^"]*)" should be visible$/) do |arg1|
  expect(page).to have_selector(arg1, visible: true)
end

Then(/^"([^"]*)" should not be visible$/) do |arg1|
  expect(page).to have_selector(arg1, visible: false)
end

Then(/^"([^"]*)" should be checked$/) do |arg1|
  my_box = find(arg1)
  expect(my_box).to be_checked  # Rspec 2.11
end

Then(/^"([^"]*)" should not be checked$/) do |arg1|
  my_box = find(arg1)
  expect(my_box).to_not be_checked  # Rspec 2.11
end

### NEW 
Then(/^I should see ignore in the url$/) do
  expect(page).to have_current_path(schedule_courses_path(ignore: 'true'))
end
