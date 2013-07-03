# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2013 Alexandre Terrasa <alexandre@moz-code.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Nit wrapping of the wiringPi library (http://wiringpi.com/)
# WiringPi is an Arduino wiring-like library written in C
# and released under the GNU LGPLv3 license which is usable
# from C and C++ and many other languages with suitable wrappers
module wiringPi

in "C Header" `{
	#include <wiringPi.h>

	typedef struct {
		int id;
	} CRPiPin;
`}


# One of the setup functions must be called at the start of your program
# or your program will fail to work correctly.
redef class Object
	# This initialises wiringPi and assumes that the calling program is
	# going to be using the wiringPi pin numbering scheme.
	fun wiringPi_setup `{ wiringPiSetup(); `}
	# Same as wiringPi_setup, however it allows the calling programs to
	# use the Broadcom GPIO pin numbers directly with no re-mapping.
	fun wiringPi_setup_gpio `{ wiringPiSetupGpio(); `}
	# Identical to wiringPi_setup, however it allows the calling
	# programs to use the physical pin numbers on the P1 connector only.
	fun wiringPi_setup_phys `{ wiringPiSetupPhys(); `}
	# This initialises wiringPi but uses the /sys/class/gpio interface
	# rather than accessing the hardware directly.
	fun wiringPi_setup_sys `{ wiringPiSetupSys(); `}
end

# A Pin
extern class RPiPin `{ CRPiPin *`}
	# The pin 'id' depends on wiringPi setup used
	new (id: Int) `{
		CRPiPin *pin = malloc( sizeof(CRPiPin) );
		pin->id = id;
		return pin;
	`}

	fun id: Int `{ return recv->id; `}

	# This sets the mode of a pin to either:
	#	INPUT
	#	OUTPUT
	#	PWM_OUTPUT
	#	GPIO_CLOCK
	# Note that only wiringPi pin 1 (BCM_GPIO 18) supports PWM output
	# and only wiringPi pin 7 (BCM_GPIO 4) supports CLOCK output modes.
	fun mode(mode: RPiPinMode) `{ pinMode(recv->id, mode); `}

	# This sets the pull-up or pull-down resistor mode on the given pin,
	# which should be set as an input.
	# The BCM2835 has both pull-up an down internal resistors.
	# The parameter pud should be:
	#	PUD_OFF, (no pull up/down)
	#	PUD_DOWN (pull to ground)
	#	PUD_UP (pull to 3.3v)
	# The internal pull up/down resistors have a value of approximately
	# 50Kohms on the Raspberry Pi.
	fun pullup_dncontrol(pud: PUDControl) `{ pullUpDnControl(recv->id, pud); `}

	# Writes the value HIGH or LOW (1 or 0) to the given pin which must
	# have been previously set as an output.
	fun write(high: Bool) `{ digitalWrite(recv->id, high? HIGH: LOW); `}

	# Writes the value to the PWM register for the given pin.
	# The Raspberry Pi has one on-board PWM pin, pin 1 (BMC_GPIO 18, Phys 12)
	# and the range is 0-1024.
	# Other PWM devices may have other PWM ranges.
	fun pwm_write(value: Int) `{ pwmWrite(recv->id, value); `}

	# This function returns the value read at the given pin.
	# It will be HIGH or LOW (1 or 0) depending on the logic level at the pin.
	fun read: Bool `{ return digitalRead(recv->id) == HIGH? true: false; `}
end

extern class RPiPinMode `{ int `}
	new input_mode `{ return INPUT; `}
	new output_mode `{ return OUTPUT; `}
	new pwm_mode `{ return PWM_OUTPUT; `}
	new clock_mode `{ return GPIO_CLOCK; `}
end

extern class PUDControl `{ int `}
	new off `{ return PUD_OFF; `}
	new down `{ return PUD_DOWN; `}
	new up `{ return PUD_UP; `}
end
