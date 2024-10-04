###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SiVoiceLoader extends RefCounted

const FILE_EXTENSION := "sivoice"


static func load(path: String) -> bool:
	if path.get_extension() != FILE_EXTENSION:
		printerr("SiVoiceLoader: The SFX file must have a .%s extension." % [ FILE_EXTENSION ])
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr("SiVoiceLoader: Failed to open the file at '%s' for reading (code %d)." % [ path, error ])
		return false

	var success := _read_file(file)
	if not success:
		printerr("SiVoiceLoader: Failed to parse the file at '%s'." % [ path ])
		return false

	return true


static func _read_file(file: FileAccess) -> bool:
	var file_contents := file.get_as_text()
	if file_contents.is_empty():
		printerr("SiVoiceLoader: Empty content in the file at '%s'." % [ file.get_path() ])
		return false

	var inner_voice := SiONVoice.new()
	var voice_index := inner_voice.set_by_mml(file_contents)
	if voice_index == -1:
		printerr("SiVoiceLoader: Invalid content in the file at '%s'." % [ file.get_path() ])
		return false

	var op_count = inner_voice.get_channel_params().operator_count
	var voice: Voice = null

	match inner_voice.get_chip_type():
		SiONDriver.CHIP_SIOPM:
			voice = SiOPMVoice.new(op_count)

		SiONDriver.CHIP_OPL:
			voice = OPLVoice.new(op_count)

		SiONDriver.CHIP_OPM:
			voice = OPMVoice.new(op_count)

		SiONDriver.CHIP_OPN:
			voice = OPNVoice.new(op_count)

		SiONDriver.CHIP_OPX:
			voice = OPXVoice.new(op_count)

		SiONDriver.CHIP_MA3:
			voice = MA3Voice.new(op_count)

	voice.voice = inner_voice
	inner_voice.update_volumes = true
	voice.volume.value = int(100 * (inner_voice.velocity / float(Voice.MAX_VOLUME)))

	var voice_data: Array[int] = []
	match inner_voice.get_chip_type():
		SiONDriver.CHIP_SIOPM:
			voice_data = inner_voice.get_params()

		SiONDriver.CHIP_OPL:
			voice_data = inner_voice.get_params_opl()

		SiONDriver.CHIP_OPM:
			voice_data = inner_voice.get_params_opm()

		SiONDriver.CHIP_OPN:
			voice_data = inner_voice.get_params_opn()

		SiONDriver.CHIP_OPX:
			voice_data = inner_voice.get_params_opx()

		SiONDriver.CHIP_MA3:
			voice_data = inner_voice.get_params_ma3()

	for i in voice_data.size():
		voice.data[i].value = voice_data[i]

	Controller.edit_sfx(null, voice)
	return true
