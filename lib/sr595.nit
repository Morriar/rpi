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

# Nit representation of a 74×595 Shift Register
module sr595

import wiringPi

# The ShiftRegister class represent a daisy chain of
# 74×595 shift register
class ShiftRegister
	private var registers: Array[Bool]
	private var nb_pins: Int
	private var ser: RPiPin
	private var rclk: RPiPin
	private var srclk: RPiPin

	init(nb_pins, ser_pin, rclk_pin, srclk_pin: Int) do
		# configure pin layout
		self.nb_pins = nb_pins
		self.ser = new RPiPin(7)
		self.rclk = new RPiPin(6)
		self.srclk = new RPiPin(5)
		clear_registers
		# enable output mode on shift register output
		ser.mode(new RPiPinMode.output_mode)
		rclk.mode(new RPiPinMode.output_mode)
		srclk.mode(new RPiPinMode.output_mode)
	end

	# write 'state' on register 'reg'
	fun write(reg: Int, state: Bool) do
		registers[reg] = state
		write_registers
	end

	# write all registers
	fun write_all(regs: Array[Bool]) do
		assert regs.length == nb_pins
		registers = regs
		write_registers
	end

	# clear all registers
	fun clear_registers do
		registers = new Array[Bool].filled_with(false, nb_pins)
		write_registers
	end

	private fun write_registers do
		rclk.write(false)
		var i = registers.length - 1
		while i >= 0 do
			var reg = registers[i]
			srclk.write(false)
			ser.write(reg)
			srclk.write(true)
			i -= 1
		end
		rclk.write(true)
	end
end
