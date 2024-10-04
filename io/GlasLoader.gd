###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name GlasLoader extends RefCounted

const FILE_EXTENSION := "glas"

const FORMAT_HINT := "GLAS" # Hopefully nobody uses this :)
const SECTION_SAMPLE_HINT := "smpl"
const SECTION_VOICE_HINT := "voic"


static func load(path: String) -> bool:
	if path.get_extension() != FILE_EXTENSION:
		printerr("GlasLoader: The SFX file must have a .%s extension." % [ FILE_EXTENSION ])
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr("GlasLoader: Failed to open the file at '%s' for reading (code %d)." % [ path, error ])
		return false

	var success := _read_file(file)
	if not success:
		printerr("GlasLoader: Failed to parse the file at '%s'." % [ path ])
		return false

	return true


static func _read_file(file: FileAccess) -> bool:
	file.seek(0)
	if ByteArrayUtil.read_string(file, 4) != FORMAT_HINT:
		return false

	var version_major := file.get_16()
	var version_minor := file.get_16()

	if version_major == 1:
		return _read_file_v1(file)

	printerr("GlasLoader: Unsupported version %d.%d in the file at '%s'." % [ version_major, version_minor, file.get_path() ])
	return false


static func _read_file_v1(file: FileAccess) -> bool:
	var sample := Sample.new()
	var voice: Voice = null

	while file.get_position() < file.get_length():
		var section_name := ByteArrayUtil.read_string(file, 4)
		var section_size := file.get_16()

		if (file.get_position() + section_size > file.get_length()):
			printerr("GlasLoader: File content length mismatch in the file at '%s' (section '%s' goes out of bounds)." % [ file.get_path(), section_name ])
			return false

		match section_name:
			SECTION_SAMPLE_HINT:
				sample.length.value = file.get_8()
				sample.note.value = file.get_8()

				section_size -= 2

			SECTION_VOICE_HINT:
				# Parse the header part.

				var header_size := file.get_16()
				section_size -= header_size

				var voice_type := file.get_8()
				var ch_param_count := file.get_8()
				var op_param_count := file.get_8()
				var op_count := file.get_8()

				header_size -= 4

				match voice_type:
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

				if not voice:
					printerr("GlasLoader: Unsupported voice type (%d) in the file at '%s'." % [ voice_type, file.get_path() ])
					return false

				if voice.get_channel_param_count() != ch_param_count:
					printerr("GlasLoader: Invalid number of channel parameters (%d) for the voice type %d in the file at '%s'." % [ ch_param_count, voice_type, file.get_path() ])
					return false

				if voice.get_operator_param_count() != op_param_count:
					printerr("GlasLoader: Invalid number of operator parameters (%d) for the voice type %d in the file at '%s'." % [ op_param_count, voice_type, file.get_path() ])
					return false

				file.seek(file.get_position() + header_size) # Advance the position.

				# Parse the body part.

				var body_size := file.get_16()
				section_size -= body_size

				voice.volume.value = file.get_8()
				body_size -= 1

				var data_size := file.get_16()
				body_size -= data_size

				var voice_data_size := int(data_size / 2.0)
				var expected_data_size := ch_param_count + op_param_count * op_count
				if voice_data_size != expected_data_size:
					printerr("GlasLoader: Voice data size mismatch in the file at '%s' (expected %d, got %d)." % [ file.get_path(), expected_data_size, voice_data_size ])
					return false

				for i in voice_data_size:
					var raw_data := file.get_buffer(2)
					voice.data[i].value = raw_data.decode_s16(0)

				file.seek(file.get_position() + body_size) # Advance the position.

			_:
				print("GlasLoader: Encountered an unknown section ('%s') in the file at '%s'." % [ section_name, file.get_path() ])

		file.seek(file.get_position() + section_size) # Advance the position.

	Controller.edit_sfx(sample, voice)
	return true
