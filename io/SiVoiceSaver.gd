###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SiVoiceSaver extends RefCounted

const FILE_EXTENSION := "sivoice"


static func save(path: String) -> bool:
	if path.get_extension() != FILE_EXTENSION:
		printerr("SiVoiceSaver: The voice file must have a .%s extension." % [ FILE_EXTENSION ])
		return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr("SiVoiceSaver: Failed to open the file at '%s' for writing (code %d)." % [ path, error ])
		return false

	var file_contents := _write_file()
	if file_contents.is_empty():
		printerr("SiVoiceSaver: Failed to generate the file at '%s'." % [ path ])
		return false

	# Try to write the file with the new contents.

	file.store_string(file_contents)
	error = file.get_error()
	if error != OK:
		printerr("SiVoiceSaver: Failed to write to the file at '%s' (code %d)." % [ path, error ])
		return false

	return true


static func _write_file() -> String:
	var voice_params := Controller.voice_manager.get_voice_params()
	if not voice_params || not voice_params.voice:
		return ""

	return voice_params.voice.get_mml(0)
