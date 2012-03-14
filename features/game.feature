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

Scenario: The user starts a game and then immediately loses
  Given the field
  """
  . * .

  """
  When I click on the cell in the 1st row and 1st column
  When I click on the cell in the 1st row and 2nd column
  Then I should lose
  And I should see the game
  """
  1 % .
  """

Scenario: The user is efficient at playing expert games
  Given the field
  """
  . . . . . . . . . * * . . . * . . . . . . . . . . . . . * .
  . . . * . * . . . . . . . . * . . . * . . . * * * . * . . .
  . . . . . . . . . . . . * . * * . . . . * * . . . . * . . .
  * . . . * . * * . . . . . * . . . . . . . . . . . . . . * .
  . . . . . . . . . . . * . . * . . . . . . . . . . * . . * .
  * . . . . . . . . . * * . . . . . . . . . . * . . * . . . .
  . . . . . . . . . . . . . . . . * * . . * . . . . . * . . .
  * * * . . . . . . * . . . . . . . . . . . . * . . . * . * .
  * . * . . * . * . . . . . . * * . . . . * . . . . * . . . .
  . . . * * . * . . . . . . . . . . . . . . . . . . . . . . *
  . . . . . . . . * . . . * . . . . . * . . . * . . . . . . .
  . . * . . . . * . . * . . . . . . * . . . . . * . * * . * .
  . . . . * . . . . . * * . . * . . . * * . . . . * . . . . .
  . . . * . . . . * . * . . . . . . * . . * * . . * . . * . *
  . * * . * * . . . . * * * * . . * . . . . . * . . . . . . *
  . . . . . . . . . . . . . . . * . . . . * . * . . . . * . .
  """
  Then I can win the game without guessing
  And I should finish the game in 30 seconds or less