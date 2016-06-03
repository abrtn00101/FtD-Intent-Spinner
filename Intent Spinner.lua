--[[
-- Intent Spinner Script --
Version 1.1
by RedBOY

Required libraries:
* Modified Madwand EulerAngles library

Uses a spinner as a user-input interface

To use, add a spinner to your construct and bind complex control buttons to it.
Then you can use either a complex controller or an ACB that transforms user
input on a Vehicle Controller or Ship's Wheel into a complex control button to
spin it. The script reads the spin and determines what to do.

As an alternative to using complex controls, you can also use the left and right
sail buttons on the Ship's Wheel if your spinner is set up with a vertical axis,
or, of course, a Spin Controller.

The script checks for six states:
* Button for positive spin pressed for a short time
* Button for positive spin currently held down
* Button for positive spin released after being held down (positive long press)
* Button for negative spin pressed for a short time
* Button for negative spin currently held down
* Button for negative spin released after being held down (negative long press)

While you can use all six states in the same Intent Spinner instance, you will
probably only need two to four of these states for most uses. Keep in mind that
when you use the library to detect if the button is being actively held down,
this does not override the short or long button press intent states. Therefore,
if a button is held down in one direction and then released, the script will try
to call the function for the button-currently-being-held-down state while it is
held down and then try to call the function for the short- or long-button-press
state after it is released depending on how long the button was pressed.
--]]

-- This is an example pseudo-constant nonconstants table for use with the
-- IntentSpinner library
ISConstants = {
  -- The index of the spinner used to determine user intent
  SPINNER_INDEX = 1,

  -- For determining long presses, the number of consecutive calls to Read()
  -- before the intent is classed as a long button press. Does not affect the
  -- button held down state. When set to 0 or less, completely disables the
  -- short-button-press state.
  HOLD_TIME = 20,     

  -- If true, positive spin yields a negative value
  REVERSE = false,

  -- If true, the long press function will only be called after the held button
  -- is released.
  WAIT_FOR_RELEASE = false,

  -- The functions for each state. Set the ones you don't need to nil.
  POSITIVE_SHORT_PRESS = function(I) I:LogToHud('Positive short press') end,
  POSITIVE_LONG_PRESS = function(I) I:LogToHud('Positive long press') end,
  POSITIVE_BUTTON_HELD = function(I) I:LogToHud('Positive button held down') end,
  NEGATIVE_SHORT_PRESS = function(I) I:LogToHud('Negative short press') end,
  NEGATIVE_LONG_PRESS = function(I) I:LogToHud('Negative long press') end,
  NEGATIVE_BUTTON_HELD = function(I) I:LogToHud('Negative button held down') end
}

-- The library itself
function IntentSpinner(I, constants, eulerAngles)
  local self = {}
  self.iface = I
  self.Constants = constants
  self.EA = eulerAngles
  self.lastAngle = 180
  self.isPositive = true
  self.newIntent = false
  self.intentPerformed = false
  self.holdCount = 0

  -- Read the spinner. Run this, perferably, during every update cycle.
  function self.Read(self)
    local currentAngle = math.fmod(self.EA:GetCurrentAngleDeg(self.Constants.SPINNER_INDEX) + 180, 360)
    local longPress = false
    local intentCompleted = false

    if currentAngle ~= self.lastAngle then
      if self.holdCount == 0 then
        self.newIntent = true

        if currentAngle > self.lastAngle then
          self.isPositive = true
        else
          self.isPositive = false
        end

        if self.Constants.REVERSE then self.isPositive = not self.isPositive end
      end

      self.holdCount = self.holdCount + 1

      if self.isPositive then
        if self.Constants.POSITIVE_BUTTON_HELD then self.Constants.POSITIVE_BUTTON_HELD(self.iface) end
      else
        if self.Constants.NEGATIVE_BUTTON_HELD then self.Constants.NEGATIVE_BUTTON_HELD(self.iface) end
      end

      if self.holdCount >= self.Constants.HOLD_TIME then
        if not self.intentPerformed and not self.Constants.WAIT_FOR_RELEASE then
          longPress = true
          self.intentPerformed = true
        end
      end
    elseif self.newIntent then
      if self.holdCount < self.Constants.HOLD_TIME and not self.intentPerformed then
        if self.isPositive then
          if self.Constants.POSITIVE_SHORT_PRESS then self.Constants.POSITIVE_SHORT_PRESS(self.iface) end
        else
          if self.Constants.NEGATIVE_SHORT_PRESS then self.Constants.NEGATIVE_SHORT_PRESS(self.iface) end
        end
      else
        longPress = true
      end
      
      intentCompleted = true
      self.holdCount = 0
      self.newIntent = false
      self.intentPerformed = false
    end

    if longPress then
      if self.isPositive then
        if self.Constants.POSITIVE_LONG_PRESS then self.Constants.POSITIVE_LONG_PRESS(self.iface) end
      else
        if self.Constants.NEGATIVE_LONG_PRESS then self.Constants.NEGATIVE_LONG_PRESS(self.iface) end
      end
    end

    self.lastAngle = currentAngle
    return intentCompleted
  end

  return self
end