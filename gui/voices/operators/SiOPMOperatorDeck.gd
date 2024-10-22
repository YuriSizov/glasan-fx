###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SiOPMOperatorDeck extends MarginContainer

var operator_data: Array[VoiceKnob] = []:
	set = set_operator_data

@onready var _attack_rate: RollerKnob = %AttackKnob
@onready var _decay_rate: RollerKnob = %DecayKnob
@onready var _sustain_rate: RollerKnob = %SustainKnob
@onready var _release_rate: RollerKnob = %ReleaseKnob


func _ready() -> void:
	_update_knobs()


func set_operator_data(value: Array[VoiceKnob]) -> void:
	operator_data = value
	_update_knobs()


func _update_knobs() -> void:
	if not is_node_ready() || operator_data.is_empty():
		return

	#BaseVoiceDeck.setup_knob_control(_wave_shape_knob, operator_data[SiOPMVoice.OperatorParam.WS])

	BaseVoiceDeck.setup_roller_knob(_attack_rate, operator_data[SiOPMVoice.OperatorParam.AR])
	BaseVoiceDeck.setup_roller_knob(_decay_rate, operator_data[SiOPMVoice.OperatorParam.DR])
	BaseVoiceDeck.setup_roller_knob(_sustain_rate, operator_data[SiOPMVoice.OperatorParam.SR])
	BaseVoiceDeck.setup_roller_knob(_release_rate, operator_data[SiOPMVoice.OperatorParam.RR])
