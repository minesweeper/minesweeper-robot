## Instructions

You can run the robot using the script 'minesweeper_robot' under bin

You can pass three arguments:

* Number of times to play
* Location of game (default is 'github')
* Level (default is 'expert')

For example:

	$ ./bin/minesweeper_robot 10 github beginner

## Detailed logging

You can log to console by setting the INFO environment variable

For example:

	$ INFO=Y ./bin/minesweeper_robot 10

## Taking screenshots of guesses

You can take screenshots of all guesses by setting the GUESS_SHOTS environment variable.

For example:

	$ GUESS_SHOTS=Y ./bin/minesweeper_robot 10

## Rspec & Cucumber Specs

You can run these via rake

* rake spec (rspec)
* rake features (cucumber)