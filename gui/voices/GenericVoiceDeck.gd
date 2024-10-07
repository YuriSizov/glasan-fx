###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name GenericVoiceDeck extends PanelContainer

const KNOB_SCENE := preload("res://gui/components/KnobControl.tscn")

var voice: Voice = null:
	set = set_voice

@onready var _operator_button: Button = %OperatorButton
@onready var _randomize_button: Button = %RandomizeButton
@onready var _knobs_container: VBoxContainer = %Knobs


func _ready() -> void:
	_update_knobs()

	_operator_button.pressed.connect(func() -> void:
		if voice:
			voice.add_operator()
			_update_knobs()
	)

	_randomize_button.pressed.connect(func() -> void:
		if voice:
			voice.randomize_data()
			_update_knobs()
	)


# Voice management.

func set_voice(value: Voice) -> void:
	if voice == value:
		return

	voice = value
	_update_knobs()


# Widgets.


func _update_knobs() -> void:
	if not is_inside_tree():
		return

	# Remove all existing knobs.
	# FIXME: This is pretty unnecessary, unless the voice itself changes. Should be just an update.

	for child_node in _knobs_container.get_children():
		_knobs_container.remove_child(child_node)
		child_node.queue_free()

	# Create voice knobs.

	var volume_knob := _create_knob(voice.volume)
	_knobs_container.add_child(volume_knob)

	# Create channel knobs.

	var channel_data := voice.get_channel_data()

	var channel_label := Label.new()
	channel_label.text = "CHANNEL KNOBS"
	_knobs_container.add_child(channel_label)

	var channel_box := HBoxContainer.new()
	channel_box.theme_type_variation = "KnobHBox"
	_knobs_container.add_child(channel_box)

	for i in channel_data.size():
		var knob_data := channel_data[i]
		var knob := _create_knob(knob_data)
		channel_box.add_child(knob)

	# Create operator knobs for each operator.

	for i in voice.get_operator_count():
		var operator_data := voice.get_operator_data(i)

		var operator_label := Label.new()
		operator_label.text = "OPERATOR #%d KNOBS" % [ i + 1 ]
		_knobs_container.add_child(operator_label)

		var operator_box := GridContainer.new()
		operator_box.columns = 3
		operator_box.theme_type_variation = "KnobGrid"
		_knobs_container.add_child(operator_box)

		for j in operator_data.size():
			var knob_data := operator_data[j]
			var knob := _create_knob(knob_data)
			operator_box.add_child(knob)


func _create_knob(knob_data: VoiceKnob) -> KnobControl:
	var knob := KNOB_SCENE.instantiate()
	knob.knob_data = knob_data
	knob.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	return knob
