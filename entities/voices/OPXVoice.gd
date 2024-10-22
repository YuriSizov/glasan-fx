###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPXVoice extends Voice

const OPX_CH_PARAMS := 2
const OPX_OP_PARAMS := 12

enum ChannelParam {
	AL, FB
}
enum OperatorParam {

}


func _init(op_count: int = 1) -> void:
	super(op_count)

	voice.set_chip_type(SiONDriver.CHIP_OPX)
	_channel_param_count = OPX_CH_PARAMS
	_operator_param_count = OPX_OP_PARAMS

	data.clear()
	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * op_count)

	# Channel params.

	data[0] = VoiceKnob.new("AL", 0, 15)
	data[1] = VoiceKnob.new("FB", 0, 7)

	# Operator params.

	for i in op_count:
		add_operator()

	_connect_voice_data()
	_update_voice_data()


func _add_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index >= MAX_OPERATORS:
		return

	var data_index := OPX_CH_PARAMS + OPX_OP_PARAMS * operator_index
	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * (operator_index + 1))

	data[data_index + 0]  = VoiceKnob.new("WS", 0, 135) # 0-7 for MA-3, 8-135 for custom.
	data[data_index + 0].set_safe_range(0, 7)

	data[data_index + 1]  = VoiceKnob.new("AR", 0, 31)
	data[data_index + 1].value = 31
	data[data_index + 2]  = VoiceKnob.new("DR", 0, 31)
	data[data_index + 3]  = VoiceKnob.new("SR", 0, 31)
	data[data_index + 3].value = 16
	data[data_index + 4]  = VoiceKnob.new("RR", 0, 15)
	data[data_index + 4].value = 8

	data[data_index + 5]  = VoiceKnob.new("SL", 0, 15)
	data[data_index + 6]  = VoiceKnob.new("TL", 0, 127)
	data[data_index + 7]  = VoiceKnob.new("KR", 0, 3)

	data[data_index + 8]  = VoiceKnob.new("ML", 0, 15)
	data[data_index + 8].value = 1
	data[data_index + 9]  = VoiceKnob.new("D1", 0, 7)
	data[data_index + 10] = VoiceKnob.new("D2", 0, 999) # No known limit.
	data[data_index + 11] = VoiceKnob.new("AM", 0, 3)


func _remove_operator() -> void:
	var operator_index := get_operator_count()
	if operator_index == 1:
		return

	data.resize(OPX_CH_PARAMS + OPX_OP_PARAMS * (operator_index - 1))


func _randomize_channel() -> void:
	var ch_data := get_channel_data()
	ch_data[1].randomize_value() # FB


func _randomize_operator(index: int) -> void:
	var op_data := get_operator_data(index)

	op_data[0].randomize_value() # WS
	op_data[7].randomize_value() # KR
	op_data[8].randomize_value() # ML
	op_data[9].randomize_value() # D1
	op_data[10].randomize_value() # D2
