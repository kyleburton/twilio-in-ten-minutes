Feature: SMS Workflow Test
  In order to test SMS functionality I'd like to Simulate SMS interactions.

  Background: As part of each Scenario I want to set my defaults.
    Given my telephone number is "(100) 000-0001"
    And I am testing the "SMSCard" workflow.

  Scenario: I text in help.
    When I text "Help"
    Then I recieve an sms that contains "Whoa, hey there!"

