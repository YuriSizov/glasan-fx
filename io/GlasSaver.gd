###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name GlasSaver extends RefCounted

const FILE_EXTENSION := "glas"

const FORMAT_HINT := "GLAS" # Hopefully nobody uses this :)
const SECTION_SAMPLE_HINT := "smpl"
const SECTION_VOICE_HINT := "voic"

const FORMAT_VERSION_MAJOR := 1 # Changes when forward compatibility breaks.
const FORMAT_VERSION_MINOR := 1 # Changes when new data is added without breaking forward compatibility.


static func save(path: String) -> bool:
	if path.get_extension() != FILE_EXTENSION:
		printerr("GlasSaver: The SFX file must have a .%s extension." % [ FILE_EXTENSION ])
		return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr("GlasSaver: Failed to open the file at '%s' for writing (code %d)." % [ path, error ])
		return false

	var file_buffer := _write_file()
	if file_buffer.is_empty():
		printerr("GlasSaver: Failed to generate the file at '%s'." % [ path ])
		return false

	# Try to write the file with the new contents.

	file.store_buffer(file_buffer)
	error = file.get_error()
	if error != OK:
		printerr("GlasSaver: Failed to write to the file at '%s' (code %d)." % [ path, error ])
		return false

	return true


static func _write_file() -> PackedByteArray:
	var buffer := PackedByteArray()

	var sample_params := Controller.voice_manager.get_sample_params()
	if not sample_params:
		return buffer

	var voice_params := Controller.voice_manager.get_voice_params()
	if not voice_params || not voice_params.voice:
		return buffer

	ByteArrayUtil.write_string(buffer, FORMAT_HINT)
	ByteArrayUtil.write_uint16(buffer, FORMAT_VERSION_MAJOR)
	ByteArrayUtil.write_uint16(buffer, FORMAT_VERSION_MINOR)

	# Sample params section.

	ByteArrayUtil.write_string(buffer, SECTION_SAMPLE_HINT)

	var sample_section := _write_sample_section(sample_params)
	ByteArrayUtil.write_uint16(buffer, sample_section.size())
	buffer.append_array(sample_section)

	# Voice params section.

	ByteArrayUtil.write_string(buffer, SECTION_VOICE_HINT)

	var voice_section := _write_voice_section(voice_params)
	ByteArrayUtil.write_uint16(buffer, voice_section.size())
	buffer.append_array(voice_section)

	return buffer


static func _write_sample_section(sample_params: Sample) -> PackedByteArray:
	var section_buffer := PackedByteArray()

	ByteArrayUtil.write_uint8(section_buffer, sample_params.length.value)
	ByteArrayUtil.write_uint8(section_buffer, sample_params.note.value)

	return section_buffer


static func _write_voice_section(voice_params: Voice) -> PackedByteArray:
	var section_buffer := PackedByteArray()

	# Section header.

	ByteArrayUtil.write_uint16(section_buffer, 4) # Header size in this version.

	ByteArrayUtil.write_uint8(section_buffer, voice_params.voice.get_chip_type())
	ByteArrayUtil.write_uint8(section_buffer, voice_params.get_channel_param_count())
	ByteArrayUtil.write_uint8(section_buffer, voice_params.get_operator_param_count())
	ByteArrayUtil.write_uint8(section_buffer, voice_params.get_operator_count())

	# Section body.

	ByteArrayUtil.write_uint16(section_buffer, 3 + voice_params.data.size() * 2) # Body size in this version.

	ByteArrayUtil.write_uint8(section_buffer, voice_params.volume.value)

	ByteArrayUtil.write_uint16(section_buffer, voice_params.data.size() * 2)
	for knob_data in voice_params.data:
		ByteArrayUtil.write_int16(section_buffer, knob_data.value)

	return section_buffer
