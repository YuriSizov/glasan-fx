###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name VoiceKnob extends RefCounted

signal value_changed()

const MAX_INT := 9999 # Just some reasonably big value when there is no limit.

@export var label: String = "XX"
@export var value: int = 0:
	set = set_value

@export var min_value: int = 0
@export var max_value: int = 1
@export var min_safe: int = 0
@export var max_safe: int = 1


func _init(knob_label: String, knob_min: int = -MAX_INT, knob_max: int = MAX_INT) -> void:
	label = knob_label

	min_value = knob_min
	max_value = knob_max
	min_safe = knob_min
	max_safe = knob_max

	value = min_value


# Value management.

func set_value(v: int) -> void:
	var clamped := clampi(v, min_value, max_value)
	if value == clamped:
		return

	value = clamped
	value_changed.emit()


func randomize_value() -> void:
	value = randi_range(min_safe, max_safe)
	value_changed.emit()


func set_safe_range(knob_min_safe: int, knob_max_safe: int) -> void:
	min_safe = knob_min_safe
	max_safe = knob_max_safe
