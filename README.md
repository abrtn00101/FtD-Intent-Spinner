# FtD-Intent-Spinner v1.1
*by RedBOY*

A library that simplifies using a spinner block as a user input interface.


## Required libraries:
* Modified Madwand EulerAngles library

## Usage
Add a spinner to your construct and bind complex control buttons to it. Then, you can use either a complex controller or an ACB that transforms user input on a Vehicle Controller or Ship's Wheel into a complex control button to spin it. The script reads the spin and determines what to do.

As an alternative to using complex controls, you can also use the left and right sail buttons on the Ship's Wheel if your spinner is set up with a vertical axis, or, of course, a Spin Controller.

The script checks for six states:
* Button for positive spin pressed for a short time
* Button for positive spin currently held down
* Button for positive spin released after being held down (positive long press)
* Button for negative spin pressed for a short time
* Button for negative spin currently held down
* Button for negative spin released after being held down (negative long press)

## Limitations
While you can use all six states in the same Intent Spinner instance, you will probably only need two to four of these states for most uses. Keep in mind that when you use the library to detect if the button is being actively held down, this does not override the short or long button press intent states. Therefore, if a button is held down in one direction and then released, the script will try to call the function for the button-currently-being-held-down state while it is held down and then try to call the function for the short- or long-button-press state after it is released depending on how long the button was pressed.
