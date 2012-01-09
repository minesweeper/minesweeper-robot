Feature: User plays a game

Scenario: The user starts a game and then pauses to reflect
  Given the field
  """
  . .
  . .

  """
  Then I should see the game
  """
  . .
  . .
  """

Scenario: The user starts a game and then immediately wins
  Given the field
  """
  . *

  """
  When I click on the cell in the 1st row and 1st column
  Then I should win
  And I should see the game
  """
  1 .
  """