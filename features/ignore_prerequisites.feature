Feature: Ignore Prerequesites
  
  As a student,
  So that I can just explore courses I'm interested in,
  I should see an option to disable prerequisites for classes to recommend.

Background: I am on the user page
  
  Given I am on the welcome page
  And I login as "Michael"
  Then I should be on the user page
  Given the following courses exist:
  | title                   | number      |
  | ABCD                    | CS170       |
  | EFGH                    | CS188       |
  | IJKL                    | CS169       |
  | MNOP                    | CS189       |
  
  And the following prerequisites exist:
  | course | number |
  | CS188  | CS61A  |

# Given the following courses I have taken exist: empty table
  
Scenario: Disable Prereqs box is checked
  When I check "#Disable_prereq"
  Given the following courses are going to be taught:
    | title | number | term       | professor |
    | ABCD  | CS170  | FA17       | Cup       |
    | EFGH  | CS188  | FA17       | Dog       |

  When I follow "Schedule"
  Then I should see "Courses You're Interested In" before "CS170"
  Then I should see "Cup"
  Then I should see "CS188"
  Then I should see "Dog"
  