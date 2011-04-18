Feature: SMS Workflow Test
  In order to test SMS functionality I'd like to Simulate SMS interactions.

  Background: As part of each Scenario I want to set my defaults.
    Given my telephone number is "(610) 555-1212"
    And I am testing the "Rsvp" workflow.

  Scenario: I rsvp to go.
    When I text "Help"
    Then I recieve an sms that contains "To RSVP, reply with"
    When I text "Ok"
    Then I recieve an sms that contains "Great, see you there"
    When I text "What's next?"
    Then I recieve an sms that contains "go find something better to do"

  Scenario: I am a failure as a human being
    When I text "Help"
    Then I recieve an sms that contains "To RSVP, reply with"
    When I text "saxaphone"
    Then I recieve an sms that contains "Enjoy your evening alone in /r/transformers."
    When I text "What's next?"
    Then I recieve an sms that contains "go find something better to do"
