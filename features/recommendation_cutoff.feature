Feature: Recommendation Cutoff

  As a student,
  So that I know the best courses.
  I should NOT be recommended courses with professor ratings lower than courses I'm already interested in.
  
Background: I have classes with previous professor ratings

  Given the following courses exist:
  | title | number |
  | ESPN  | CS188  |
  | XYZO  | CS189  |
  | DAB   | CS170  |
  And the following professors, without ratings, exist:
  | name | category |
  | Cup  | EECS     |
  | Dog  | EECS     |
  | Cat  | EECS     |
  And the following courses were taught:
  | professor | number | rating | term |
  | Cup       | CS188  | 4.0    | SP16 |
  | Dog       | CS189  | 3.0    | SP16 |
  | Cat       | CS170  | 7.0    | SP16 |
  And I am on the welcome page
  And I login as "Michael"
  And I want to take "CS188-choice"
  And I am on the courses page
  
Scenario: Displays better alternative classes to take in the future
  Given the following courses are going to be taught:
  | title | number | term       | professor |
  | EFGH  | CS188  | FA16       | Cup       |
  | IJKL  | CS189  | FA16       | Dog       |
  | MNOP  | CS170  | FA16       | Cat       |
  When I follow "Schedule"
  Then I should see "Courses You're Interested In" before "CS188"
  And I should see "CS188" before "Cup"
  And I should see "CS188" before "Best Alternative Courses"
  And I should see "CS170"
  And I should see "Best Alternative Courses" before "CS170"
  And I should not see "CS189"