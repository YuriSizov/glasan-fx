###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name WaveShape extends Object

const SHAPE_BASIC       := 0
const SHAPE_NOISE       := 1
const SHAPE_PC_NOISE    := 2
const SHAPE_MA3         := 3
const SHAPE_PULSE       := 4
const SHAPE_PULSE_SPIKE := 5
const SHAPE_RAMP        := 6
const MAX               := 7

const RANGES := {
	# [ first index, range length ]
	SHAPE_BASIC:       [   0,  12 ],   #   0- 15, 12-15 reserved.
	SHAPE_NOISE:       [  16,   6 ],   #  16- 23, 22-23 reserved.
	SHAPE_PC_NOISE:    [  24,   3 ],   #  24- 31, 27-31 reserved.
	SHAPE_MA3:         [  32,  32 ],   #  32- 63, values 15, 23, 31 aren't allowed here.
	SHAPE_PULSE:       [  64,  16 ],   #  64- 79.
	SHAPE_PULSE_SPIKE: [  80,  16 ],   #  80- 95.
	                                   #  96-127 reserved.
	SHAPE_RAMP:        [ 128, 128 ],   # 127-255.
}
