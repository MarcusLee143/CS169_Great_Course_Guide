Feature: Compare courses and their info from
    As a student,
    So that I can compare courses by semester
    I should see a table with the HKN professor rating
        course rating specific to the professor
        difficulty rating, and number of units

Background: the following courses are comparable
  Given I am on the welcome page
  And I login as "Michael"
  Then I should be on the user page
  When I follow "Compare Courses"
  And the following courses exist:
  | title | number | units |
  | ABCD  | CS61A  | 4     |
  | EFGH  | CS61B  | 4     |
  | IJKL  | CS61C  | 4     |
  | Fork  | Spoon  | 4     |
  And the following professors exist:
  | name | category |
  | Cup  | EECS     |
  | Tea  | EECS     |
  And the following courses were taught:
  | professor | number | rating |
  | Cup       | CS61A  | 5.6    |
  | Tea       | CS61A  | 3.5    |
  | Cup       | CS61B  | 6.2    |

Scenario: Adding classes to compare
  Given I fill in "course-search" with "CS61A"
  And I fill in "Search for Professor (optional)" with "Cup"
  And I press "#addCourse"
  Then I should not see "Tea"

Scenario: Adding a class without specifying a professor
  Given I fill in "Search for Course" with "CS61B"
  And I press "#addCourse"
  Then I should not see "Cup"

Scenario: User doesn't specify course
  Given I fill in "Search for Professor (optional)" with "Cup"
  And I press "#addCourse"
  Then I should not see "CS61B"
  And I should not see "4"
  And I should not see "Cup"
  And I should not see "5.9"
  And I should not see "6.2"
