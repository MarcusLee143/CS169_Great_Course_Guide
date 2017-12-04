Feature: Schedule Planning for Humanities

  As a user
  So that I can plan my humanities courses for the next year
  I would like to see a list of upcoming humanities courses taught by Distinguished Teachers

Background: I am on the user page

  Given the following courses exist:
  | title   | number      |
  | Art     | ANTHROC125A |
  | Music   | ANTHRO189   |
  | History | ASAMST172   |
  | Dance   | IDX2017     |
  And the following professors exist:
  | name          | distinguished | distinguishedYear | category | awarded |
  | Junko Habu    | true          | 2016              | HUM      | true    |
  | Xin Liu       | false         | null              | HUM      | false   |
  | Fae M. Ng     | true          | 2014              | HUM      | true    |
  | Angela Marino | false         | null              | HUM      | true    |
  And they teach the humanities classes
  And I am on the welcome page
  And I login as "Michael"
  Then I should be on the user page


Scenario: I want to see classes taught by distinguished humanities teachers

  When I follow "Schedule"
  Then I should see "Non-EECS"
  And I should see "ANTHROC125A"
  And I should not see "ANTHRO189"
  But I should see "ASAMST172"

Scenario: There are no distinguished humanities teachers teaching the next year (SAD PATH)

  Given "Junko Habu" isn't teaching "ANTHROC125A" next semester
  And "Fae M. Ng" isn't teaching "ASAMST172" next semester
  When I follow "Schedule"
  And I should not see "Junko"
  And I should not see "Xin"
  And I should not see "Fae"
  But I should see "No classes taught by a distinguished humanities professor the next semester."
  And I should see "Please see your advisor for more details."

Scenario: I want to see classes by all awarded humanities teachers

  When I follow "Schedule"
  Then I should see "Non-EECS"
  And I should see "Awards Tier"
  And I should see "THEATER26"
  And the page element "#blue_star" should be under class "tier_star"