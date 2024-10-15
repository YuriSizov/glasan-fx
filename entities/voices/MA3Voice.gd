###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name MA3Voice extends Voice

const MA3_CH_PARAMS := 2
const MA3_OP_PARAMS := 12


func _init(op_count: int = 1) -> void:
	super(op_count)

	voice.set_chip_type(SiONDriver.CHIP_MA3)
	_channel_param_count = MA3_CH_PARAMS
	_operator_param_count = MA3_OP_PARAMS

	data.clear()
	data.resize(MA3_CH_PARAMS + MA3_OP_PARAMS * op_count)

	# Channel params.

	data[0] = VoiceKnob.new("AL", 0, 15)
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

	var data_index := MA3_CH_PARAMS + MA3_OP_PARAMS * operator_index
	data.resize(MA3_CH_PARAMS + MA3_OP_PARAMS * (operator_index + 1))

	data[data_index + 0]  = VoiceKnob.new("WS", 0, 31)

	data[data_index + 1]  = VoiceKnob.new("AR", 0, 15)
	data[data_index + 1].value = 15
	data[data_index + 2]  = VoiceKnob.new("DR", 0, 15)
	data[data_index + 3]  = VoiceKnob.new("SR", 0, 15)
	data[data_index + 3].value = 8
	data[data_index + 4]  = VoiceKnob.new("RR", 0, 15)
	data[data_index + 4].value = 8

	data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
	data[data_index + 6]  = VoiceKnob.new("TL", 0, 63)
	data[data_index + 7]  = VoiceKnob.new("KR", 0, 1)
	data[data_index + 8]  = VoiceKnob.new("KL", 0, 3)

	data[data_index + 9]  = VoiceKnob.new("ML", 0, 15)
	data[data_index + 9].value = 1
	data[data_index + 10] = VoiceKnob.new("D1", 0, 7)
	data[data_index + 11] = VoiceKnob.new("AM", 0, 3)


func _remove_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index == 1:
		return

	data.resize(MA3_CH_PARAMS + MA3_OP_PARAMS * (operator_index - 1))


func _randomize_data() -> void:
	var ch_data := get_channel_data()
	ch_data[1].randomize_value() # FB

	for i in get_operator_count():
		var op_data := get_operator_data(i)

		op_data[0].randomize_value() # WS
		op_data[7].randomize_value() # KR
		op_data[9].randomize_value() # ML
		op_data[10].randomize_value() # D1
