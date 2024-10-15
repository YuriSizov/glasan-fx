###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPMVoice extends Voice

const OPM_CH_PARAMS := 2
const OPM_OP_PARAMS := 11


func _init(op_count: int = 1) -> void:
	super(op_count)

	voice.set_chip_type(SiONDriver.CHIP_OPM)
	_channel_param_count = OPM_CH_PARAMS
	_operator_param_count = OPM_OP_PARAMS

	data.clear()
	data.resize(OPM_CH_PARAMS + OPM_OP_PARAMS * op_count)

	# Channel params.

	data[0] = VoiceKnob.new("AL", 0, 7)
	data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		_add_operator()

	_connect_voice_data()
	_update_voice_data()


func _add_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index >= MAX_OPERATORS:
		return

	var data_index := OPM_CH_PARAMS + OPM_OP_PARAMS * operator_index
	data.resize(OPM_CH_PARAMS + OPM_OP_PARAMS * (operator_index + 1))

	data[data_index + 0]  = VoiceKnob.new("AR", 0, 31)
	data[data_index + 0].value = 31
	data[data_index + 1]  = VoiceKnob.new("DR", 0, 31)
	data[data_index + 2]  = VoiceKnob.new("SR", 0, 31)
	data[data_index + 2].value = 16
	data[data_index + 3]  = VoiceKnob.new("RR", 0, 15)
	data[data_index + 3].value = 8

	data[data_index + 4]  = VoiceKnob.new("SL", 0, 15)
	data[data_index + 5]  = VoiceKnob.new("TL", 0, 127)
	data[data_index + 6]  = VoiceKnob.new("KR", 0, 3)

	data[data_index + 7]  = VoiceKnob.new("ML", 0, 15)
	data[data_index + 7].value = 1
	data[data_index + 8]  = VoiceKnob.new("D1", 0, 7)
	data[data_index + 9]  = VoiceKnob.new("D2", 0, 3)
	data[data_index + 10] = VoiceKnob.new("AM", 0, 3)


func _remove_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index == 1:
		return

	data.resize(OPM_CH_PARAMS + OPM_OP_PARAMS * (operator_index - 1))


func _randomize_data() -> void:
	var ch_data := get_channel_data()
	ch_data[1].randomize_value() # FB

	for i in get_operator_count():
		var op_data := get_operator_data(i)

		op_data[6].randomize_value() # KR
		op_data[7].randomize_value() # ML
		op_data[8].randomize_value() # D1
		op_data[9].randomize_value() # D2
