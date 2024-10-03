###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name VoicePanel extends MarginContainer

const KNOB_SCENE := preload("res://gui/components/KnobControl.tscn")

var _voices: Array[Voice] = []
var _current_voice: Voice = null

@onready var _randomize_button: Button = %RandomizeButton
@onready var _knobs_container: VBoxContainer = %KnobsContainer

@onready var _siopm_button: Button = %SiOPMButton
@onready var _opl_button: Button = %OPLButton
@onready var _opm_button: Button = %OPMButton
@onready var _opn_button: Button = %OPNButton
@onready var _opx_button: Button = %OPXButton
@onready var _ma3_button: Button = %MA3Button


func _ready() -> void:
	_randomize_button.pressed.connect(func() -> void:
		if _current_voice:
			_current_voice.randomize_data()
			_update_knobs()
	)

	_siopm_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_SIOPM))
	_opl_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_OPL))
	_opm_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_OPM))
	_opn_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_OPN))
	_opx_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_OPX))
	_ma3_button.pressed.connect(_switch_voice_type.bind(SiONDriver.CHIP_MA3))

	_initialize_voice_types()


func _initialize_voice_types() -> void:
	_voices.resize(6)

	_voices[SiONDriver.CHIP_SIOPM] = Voice.create_siopm_voice()
	_voices[SiONDriver.CHIP_OPL] = Voice.create_opl_voice()
	_voices[SiONDriver.CHIP_OPM] = Voice.create_opm_voice()
	_voices[SiONDriver.CHIP_OPN] = Voice.create_opn_voice()
	_voices[SiONDriver.CHIP_OPX] = Voice.create_opx_voice()
	_voices[SiONDriver.CHIP_MA3] = Voice.create_ma3_voice()

	for voice in _voices:
		voice.randomize_data()

	_current_voice = _voices[0]
	Controller.voice_manager.set_voice(_current_voice)

	_update_knobs()


func _switch_voice_type(type: int) -> void:
	if type < 0 || type >= _voices.size():
		return

	_current_voice = _voices[type]
	Controller.voice_manager.set_voice(_current_voice)

	_update_knobs()


func _update_knobs() -> void:
	# Remove all existing knobs.
	# FIXME: This is pretty unnecessary, unless the voice itself changes. Should be just an update.

	for child_node in _knobs_container.get_children():
		_knobs_container.remove_child(child_node)
		child_node.queue_free()

	# Create channel knobs.

	var channel_data := _current_voice.get_channel_data()

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

	for i in _current_voice.get_operator_count():
		var operator_data := _current_voice.get_operator_data(i)

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
