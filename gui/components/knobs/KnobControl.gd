###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name KnobControl extends VBoxContainer

var knob_data: VoiceKnob = null:
	set = set_knob_data

@onready var _name_label: Label = %Name
@onready var _value_label: Label = %Value
@onready var _value_slider: HSlider = %Slider


func _ready() -> void:
	_update_controls()

	_value_slider.value_changed.connect(_update_knob_value)


func _update_controls() -> void:
	if not is_inside_tree() || not knob_data:
		return

	_name_label.text = knob_data.label
	_value_label.text = "%d" % [ knob_data.value ]

	_value_slider.set_block_signals(true)
	_value_slider.min_value = knob_data.min_value
	_value_slider.max_value = knob_data.max_value
	_value_slider.value = knob_data.value
	_value_slider.set_block_signals(false)


func set_knob_data(value: VoiceKnob) -> void:
	if knob_data == value:
		return

	knob_data = value
	_update_controls()


func force_update() -> void:
	_update_controls()


func _update_knob_value(new_value: float) -> void:
	if not knob_data:
		return

	knob_data.value = int(new_value)
	_value_label.text = "%d" % [ knob_data.value ]
