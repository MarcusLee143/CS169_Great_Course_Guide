Feature: Ignore Prerequesites
  
  As a student,
  So that I can just explore courses I'm interested in,
  I should see an option to disable prerequisites for classes to recommend.

Background: I have classes
  
  Given the following courses exist:
  | title                   | number      |
  | ABCD                    | CS170       |
  | EFGH                    | CS188       |
  | IJKL                    | CS169       |
  | MNOP                    | CS189       |
  
And the following prerequisites exist:
  | course | number |
  | CS170  | CS61A  |
  | CS188  | CS61A  |

  And the following professors exist:
  | name |
  | Cup  |
  | Dog  |
  | Cat  |

  And I am on the welcome page
  And I login as "Michael"
  Then I should be on the user page

Scenario: Ignore Prerequisties is selected
  Given the following courses are going to be taught:
  | title | number | term       | professor |
  | ABCD  | CS170  | FA16       | Cup       |
  | EFGH  | CS188  | FA16       | Dog       |
  | IJKL  | CS169  | FA16       | Cat       |

  When I follow "Schedule"
  And I follow "Ignore Prerequisites"
  Then I should see ignore in the url
  Then I should see "Click to Ignore Prerequisites"
  Then I should see "CS169"
  Then I should see "CS170"
  Then I should see "Cup"
  Then I should see "CS188"
  Then I should see "Dog"
  Then I should see "Cat"