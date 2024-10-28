###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPXOperatorDeck extends MarginContainer

var operator_data: Array[VoiceKnob] = []:
	set = set_operator_data

@onready var _wave_shape_flipper: MA3WaveShapeFlipper = %WaveShapeFlipper

@onready var _attack_rate: RollerKnob = %AttackKnob
@onready var _decay_rate: RollerKnob = %DecayKnob
@onready var _sustain_rate: RollerKnob = %SustainKnob
@onready var _release_rate: RollerKnob = %ReleaseKnob

@onready var _key_scaling_rate: RollerKnob = %KeyRateKnob
@onready var _sustain_level: RollerKnob = %SustainLevelKnob
@onready var _total_level: RollerKnob = %TotalLevelKnob

@onready var _multiple: RollerKnob = %MultipleKnob
@onready var _detune1: RollerKnob = %Detune1Knob
@onready var _detune2: TunerSlider = %Detune2Slider

@onready var _amplitude_shift: RollerKnob = %AmplitudeKnob


func _ready() -> void:
	_update_knobs()


func set_operator_data(value: Array[VoiceKnob]) -> void:
	operator_data = value
	_update_knobs()


func _update_knobs() -> void:
	if not is_node_ready() || operator_data.is_empty():
		return

	_setup_shape_flipper(_wave_shape_flipper, operator_data[OPXVoice.OperatorParam.WS])

	BaseVoiceDeck.setup_roller_knob(_attack_rate,  operator_data[OPXVoice.OperatorParam.AR])
	BaseVoiceDeck.setup_roller_knob(_decay_rate,   operator_data[OPXVoice.OperatorParam.DR])
	BaseVoiceDeck.setup_roller_knob(_sustain_rate, operator_data[OPXVoice.OperatorParam.SR])
	BaseVoiceDeck.setup_roller_knob(_release_rate, operator_data[OPXVoice.OperatorParam.RR])

	BaseVoiceDeck.setup_roller_knob(_key_scaling_rate,  operator_data[OPXVoice.OperatorParam.KR])
	BaseVoiceDeck.setup_roller_knob(_sustain_level,     operator_data[OPXVoice.OperatorParam.SL])
	BaseVoiceDeck.setup_roller_knob(_total_level,       operator_data[OPXVoice.OperatorParam.TL])

	BaseVoiceDeck.setup_roller_knob(_multiple, operator_data[OPXVoice.OperatorParam.ML])
	BaseVoiceDeck.setup_roller_knob(_detune1,  operator_data[OPXVoice.OperatorParam.D1])
	BaseVoiceDeck.setup_tuner_slider(_detune2, operator_data[OPXVoice.OperatorParam.D2])

	BaseVoiceDeck.setup_roller_knob(_amplitude_shift, operator_data[OPXVoice.OperatorParam.AM])


func _setup_shape_flipper(flipper: MA3WaveShapeFlipper, data: VoiceKnob) -> void:
	# Clear previous connections, if any.
	var connections := flipper.shape_changed.get_connections()
	for connection : Dictionary in connections:
		flipper.shape_changed.disconnect(connection["callable"])

	flipper.wave_shape = data.value

	# Connect to changes.
	flipper.shape_changed.connect(func() -> void:
		data.value = flipper.wave_shape
	)
