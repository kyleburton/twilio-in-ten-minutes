Feature: La Cosa Nostra IVR Workflow
  In order to register a credit card I want to call the La Cosa Nostra IVR
  and simulate a phone call.

  Background: As part of each Scenario I want to set my defaults.
    Given my telephone number is "(100) 000-0001"
    And I am testing the "CCard" workflow.
    And I call the IVR.

  Scenario: I register my card in one step and sign up for all services.
    Then the IVR says "Welcome to the La Cosa Nostra credit card activation system."
    And the IVR says "enter your 16 digit card number."
    When I press 1234123412341234
    Then the IVR says "Hey, well done there."
    And the IVR says "You want we should break their legs?"
    And the IVR says "To accept this contract press 1, otherwise press 2."
    When I press 1
    Then the IVR says "It is a reasonable person indeed who values protection."
    And the IVR says 
      """
      If you'd like us to take care of these 
      scumbags before they cause you any trouble, press 1.
      """
    When I press 1
    Then the IVR says "Consider it done."
    And the IVR says "Goodbye."

  Scenario: I register my card but refuse additional services.
    Then the IVR says "Welcome to the La Cosa Nostra credit card activation system."
    And the IVR says "enter your 16 digit card number."
    When I press 1234123412341234
    Then the IVR says "Hey, well done there."
    And the IVR says "You want we should break their legs?"
    And the IVR says "To accept this contract press 1, otherwise press 2."
    When I press 2
    Then the IVR says "Watch your back wiseguy!"

  Scenario: I am a complete failure
    Then the IVR says "Welcome to the La Cosa Nostra credit card activation system."
    And I mash on the keys
    Then the IVR says "you're a real smart guy aren't you?"
    And the IVR says "You have 3 chances left"
    And I mash on the keys
    Then the IVR says "You have 2 chances left"
    And I mash on the keys
    Then the IVR says "You have 1 chances left"
    And I mash on the keys
    Then the IVR says "Forget about it."
