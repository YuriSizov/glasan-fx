###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name FallbackVoiceDeck extends BaseVoiceDeck

const KNOB_SCENE := preload("res://gui/components/knobs/KnobControl.tscn")

@onready var _voice_header: VoiceDeckHeader = %VoiceHeader
@onready var _operators_header: VoiceOperatorsHeader = %OperatorsHeader

@onready var _volume_knob_control: KnobControl = %VolumeKnob
@onready var _channel_knobs_container: VBoxContainer = %ChannelKnobs
@onready var _operator_knobs_container: TabContainer = %OperatorKnobs


func _ready() -> void:
	_update_knobs()
	voice_changed.connect(_update_knobs)

	_operators_header.add_operator_pressed.connect(func() -> void:
		if voice:
			voice.add_operator()
	)
	_operators_header.remove_operator_pressed.connect(func() -> void:
		if voice:
			voice.remove_operator()
	)
	_voice_header.randomize_pressed.connect(func() -> void:
		if voice:
			voice.randomize_voice()
	)


# Knob management.

func _update_knobs() -> void:
	if not is_inside_tree():
		return

	_volume_knob_control.knob_data = voice.volume

	# Remove all existing knobs.
	# FIXME: This is pretty unnecessary, unless the voice itself changes. Should be just an update.

	for child_node in _channel_knobs_container.get_children():
		_channel_knobs_container.remove_child(child_node)
		child_node.queue_free()

	for child_node in _operator_knobs_container.get_children():
		_operator_knobs_container.remove_child(child_node)
		child_node.queue_free()

	# Create channel knobs.

	var channel_data := voice.get_channel_data()

	var channel_box := HBoxContainer.new()
	channel_box.theme_type_variation = "KnobHBox"
	_channel_knobs_container.add_child(channel_box)

	for i in channel_data.size():
		var knob_data := channel_data[i]
		var knob := _create_knob(knob_data)
		channel_box.add_child(knob)

	# Create operator knobs for each operator.

	_operators_header.operator_count = voice.get_operator_count()

	for i in voice.get_operator_count():
		var operator_data := voice.get_operator_data(i)

		var operator_container := MarginContainer.new()
		operator_container.name = [ "A", "B", "C", "D" ][i]
		operator_container.add_theme_constant_override("margin_left", 8)
		operator_container.add_theme_constant_override("margin_top", 8)
		operator_container.add_theme_constant_override("margin_right", 8)
		operator_container.add_theme_constant_override("margin_bottom", 8)
		_operator_knobs_container.add_child(operator_container)
		var operator_layout := VBoxContainer.new()
		operator_container.add_child(operator_layout)

		var operator_label := Label.new()
		operator_label.text = "OPERATOR #%d KNOBS" % [ i + 1 ]
		operator_layout.add_child(operator_label)

		var operator_box := GridContainer.new()
		operator_box.columns = 3
		operator_box.theme_type_variation = "KnobGrid"
		operator_layout.add_child(operator_box)

		for j in operator_data.size():
			var knob_data := operator_data[j]
			var knob := _create_knob(knob_data)
			operator_box.add_child(knob)


func _create_knob(knob_data: VoiceKnob) -> KnobControl:
	var knob := KNOB_SCENE.instantiate()
	knob.knob_data = knob_data
	knob.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	return knob
