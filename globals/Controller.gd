###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends Node

var voice_manager: VoiceManager = null

# Global settings.
var buffer_size: int = 2048
var bpm: int = 120

var _file_dialog: FileDialog = null
var _file_dialog_finalize_callable: Callable = Callable()


func _init() -> void:
	voice_manager = VoiceManager.new(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_file_dialog):
			_file_dialog.queue_free()


# Dialog management.

func get_file_dialog() -> FileDialog:
	if not _file_dialog:
		_file_dialog = FileDialog.new()
		_file_dialog.use_native_dialog = true
		_file_dialog.access = FileDialog.ACCESS_FILESYSTEM

		# While it should be possible to compare this _finalize_file_dialog.unbind(1) with
		# another _finalize_file_dialog.unbind(1) later on, in actuality the check in the engine
		# is faulty and explicitly returns NOT EQUAL for two equal custom callables. So we do this.
		_file_dialog_finalize_callable = _finalize_file_dialog.unbind(1)
		_file_dialog.file_selected.connect(_file_dialog_finalize_callable)
		_file_dialog.canceled.connect(_clear_file_dialog_connections)
		_file_dialog.canceled.connect(_finalize_file_dialog)

	_file_dialog.clear_filters()
	return _file_dialog


func show_file_dialog(dialog: FileDialog) -> void:
	get_tree().root.add_child(dialog)
	dialog.popup_centered()


func _clear_file_dialog_connections() -> void:
	var connections := _file_dialog.file_selected.get_connections()
	for connection : Dictionary in connections:
		if connection["callable"] != _file_dialog_finalize_callable:
			_file_dialog.file_selected.disconnect(connection["callable"])


func _finalize_file_dialog() -> void:
	_file_dialog.get_parent().remove_child(_file_dialog)


# IO management.

func save_to_file() -> void:
	var save_dialog := get_file_dialog()
	save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	save_dialog.title = "Save SFX Configuration"
	save_dialog.add_filter("*.glas", "Glasan SFX File")
	save_dialog.add_filter("*.sivoice", "GDSiON Voice Preset")
	save_dialog.current_file = ""
	save_dialog.file_selected.connect(_save_to_file_confirmed, CONNECT_ONE_SHOT)

	show_file_dialog(save_dialog)


func _save_to_file_confirmed(path: String) -> void:
	if path.is_empty():
		return

	var extension := path.get_extension()
	var success := false

	match extension:
		GlasSaver.FILE_EXTENSION:
			success = GlasSaver.save(path)
		SiVoiceSaver.FILE_EXTENSION:
			success = SiVoiceSaver.save(path)

		_:
			printerr("Controller: Unsupported file extension '.%s'" % [ extension ])

	if not success:
		printerr("Controller: Failed to save the SFX to a file.")


func load_from_file() -> void:
	var load_dialog := get_file_dialog()
	load_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	load_dialog.title = "Load SFX Configuration"
	load_dialog.add_filter("*.glas", "Glasan SFX File")
	load_dialog.add_filter("*.sivoice", "GDSiON Voice Preset")
	load_dialog.current_file = ""
	load_dialog.file_selected.connect(_load_from_file_confirmed, CONNECT_ONE_SHOT)

	show_file_dialog(load_dialog)


func _load_from_file_confirmed(path: String) -> void:
	if path.is_empty():
		return

	var extension := path.get_extension()
	var success := false

	match extension:
		GlasSaver.FILE_EXTENSION:
			success = GlasLoader.load(path)
		SiVoiceSaver.FILE_EXTENSION:
			success = SiVoiceLoader.load(path)

		_:
			printerr("Controller: Unsupported file extension '.%s'" % [ extension ])

	if not success:
		printerr("Controller: Failed to load the SFX from a file.")


func export_sample() -> void:
	var export_dialog := get_file_dialog()
	export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_dialog.title = "Export SFX"
	export_dialog.add_filter("*.wav", "Waveform Audio File")
	export_dialog.current_file = ""
	export_dialog.file_selected.connect(_export_sample_confirmed, CONNECT_ONE_SHOT)

	show_file_dialog(export_dialog)


func _export_sample_confirmed(path: String) -> void:
	if path.is_empty():
		return

	var extension := path.get_extension()
	var success := false

	match extension:
		WavExporter.FILE_EXTENSION:
			success = WavExporter.export(path)

		_:
			printerr("Controller: Unsupported file extension '.%s'" % [ extension ])

	if not success:
		printerr("Controller: Failed to export the SFX.")



# Edited data management.

func edit_sfx(sample: Sample, voice: Voice) -> void:
	if not sample && (not voice || not voice.voice):
		return

	if sample:
		voice_manager.set_sample_params(sample)

	if voice:
		voice_manager.replace_voice_params(voice)
		voice_manager.change_voice_type(voice.voice.get_chip_type())
