###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPLOperatorDeck extends MarginContainer

var operator_data: Array[VoiceKnob] = []:
	set = set_operator_data

@onready var _attack_rate: RollerKnob = %AttackKnob
@onready var _decay_rate: RollerKnob = %DecayKnob
@onready var _release_rate: RollerKnob = %ReleaseKnob
@onready var _envelope_type: RollerKnob = %EnvelopeKnob

@onready var _key_scaling_rate: RollerKnob = %KeyRateKnob
@onready var _key_scaling_level: RollerKnob = %KeyLevelKnob
@onready var _sustain_level: RollerKnob = %SustainLevelKnob
@onready var _total_level: RollerKnob = %TotalLevelKnob

@onready var _multiple: RollerKnob = %MultipleKnob

@onready var _amplitude_shift: RollerKnob = %AmplitudeKnob


func _ready() -> void:
	_update_knobs()


func set_operator_data(value: Array[VoiceKnob]) -> void:
	operator_data = value
	_update_knobs()


func _update_knobs() -> void:
	if not is_node_ready() || operator_data.is_empty():
		return

	BaseVoiceDeck.setup_roller_knob(_attack_rate,  operator_data[OPLVoice.OperatorParam.AR])
	BaseVoiceDeck.setup_roller_knob(_decay_rate,   operator_data[OPLVoice.OperatorParam.DR])
	BaseVoiceDeck.setup_roller_knob(_release_rate, operator_data[OPLVoice.OperatorParam.RR])
	BaseVoiceDeck.setup_roller_knob(_envelope_type, operator_data[OPLVoice.OperatorParam.ET])

	BaseVoiceDeck.setup_roller_knob(_key_scaling_rate,  operator_data[OPLVoice.OperatorParam.KR])
	BaseVoiceDeck.setup_roller_knob(_key_scaling_level, operator_data[OPLVoice.OperatorParam.KL])
	BaseVoiceDeck.setup_roller_knob(_sustain_level,     operator_data[OPLVoice.OperatorParam.SL])
	BaseVoiceDeck.setup_roller_knob(_total_level,       operator_data[OPLVoice.OperatorParam.TL])

	BaseVoiceDeck.setup_roller_knob(_multiple, operator_data[OPLVoice.OperatorParam.ML])

	BaseVoiceDeck.setup_roller_knob(_amplitude_shift, operator_data[OPLVoice.OperatorParam.AM])
