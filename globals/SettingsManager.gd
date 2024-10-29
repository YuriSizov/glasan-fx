###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name SettingsManager extends RefCounted

const CONFIG_PATH := "user://glasan.settings"
const CONFIG_SAVE_DELAY := 0.5

signal settings_loaded()
signal gui_scale_changed()
signal fullscreen_changed()

enum GUIScale {
	GUI_SCALE_75  = 75,
	GUI_SCALE_100 = 100,
	GUI_SCALE_125 = 125,
	GUI_SCALE_150 = 150,
	GUI_SCALE_175 = 175,
	GUI_SCALE_200 = 200,
}
# Custom values are allowed, but must be reasonably restricted.
const GUI_SCALE_MIN := 50
const GUI_SCALE_MAX := 300

# Stored properties.

var _stored_file: ConfigFile = null
var _stored_timer: SceneTreeTimer = null

# Settings: GUI.
var _gui_scale: int = GUIScale.GUI_SCALE_100
var _fullscreen: bool = false
var _windowed_size: Vector2 = Vector2.ZERO
var _windowed_maximized: bool = false
# Settings: Files.
var _last_opened_folder: String = ""


func _init() -> void:
	_windowed_size = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width", 0),
		ProjectSettings.get_setting("display/window/size/viewport_height", 0),
	)


# Persistence.

func load_settings() -> void:
	_stored_file = ConfigFile.new()

	# No recorded user profile, create it.
	if not FileAccess.file_exists(CONFIG_PATH):
		_save_settings_debounced() # Save immediately.
		return

	# Load and apply existing profile.
	var error := _stored_file.load(CONFIG_PATH)
	if error:
		printerr("SettingsManager: Failed to load app settings file at '%s' (code %d)." % [ CONFIG_PATH, error ])
		return

	# Restore saved values.

	_set_gui_scale_safe(     _stored_file.get_value("gui", "scale",      _gui_scale))
	_fullscreen =            _stored_file.get_value("gui", "fullscreen", _fullscreen)
	_windowed_maximized =    _stored_file.get_value("gui", "maximized",  _windowed_maximized)
	_set_windowed_size_safe( _stored_file.get_value("gui", "last_size",  _windowed_size))

	_last_opened_folder =    _stored_file.get_value("files", "last_folder", _last_opened_folder)

	settings_loaded.emit()


func save_settings() -> void:
	if _stored_timer:
		_stored_timer.timeout.disconnect(_save_settings_debounced)
		_stored_timer = null

	_stored_timer = Controller.get_tree().create_timer(CONFIG_SAVE_DELAY)
	_stored_timer.timeout.connect(_save_settings_debounced)


func _save_settings_debounced() -> void:
	if not _stored_file:
		return

	# Clean up the timer.
	if _stored_timer:
		_stored_timer.timeout.disconnect(_save_settings_debounced)
		_stored_timer = null

	# Record current values.

	# For compatibility with 3.0 beta 1, erase an outdated setting.
	_stored_file.set_value("gui", "scale_preset", null)

	_stored_file.set_value("gui", "scale",      _gui_scale)
	_stored_file.set_value("gui", "fullscreen", _fullscreen)
	_stored_file.set_value("gui", "maximized",  _windowed_maximized)
	_stored_file.set_value("gui", "last_size",  _windowed_size)

	_stored_file.set_value("files", "last_folder", _last_opened_folder)

	# Save everything.
	var error := _stored_file.save(CONFIG_PATH)
	if error:
		printerr("SettingsManager: Failed to save app settings file at '%s' (code %d)." % [ CONFIG_PATH, error ])
		return

	print("Successfully saved settings to %s." % [ CONFIG_PATH ] )


# Settings management.

# Settings: GUI.

func get_gui_scale() -> int:
	return _gui_scale


func get_gui_scale_factor() -> float:
	return _gui_scale / 100.0


func set_gui_scale(scale: int) -> void:
	_set_gui_scale_safe(scale)
	gui_scale_changed.emit()
	save_settings()


func _set_gui_scale_safe(scale: int) -> void:
	_gui_scale = clampi(scale, GUI_SCALE_MIN, GUI_SCALE_MAX)


func is_fullscreen() -> bool:
	return _fullscreen


func set_fullscreen(value: bool, silent: bool = false) -> void:
	_fullscreen = value
	if not silent:
		fullscreen_changed.emit()
	save_settings()


func toggle_fullscreen() -> void:
	set_fullscreen(!_fullscreen)


func get_windowed_size() -> Vector2:
	return _windowed_size


func set_windowed_size(value: Vector2) -> void:
	_set_windowed_size_safe(value)
	save_settings()


func _set_windowed_size_safe(value: Vector2) -> void:
	_windowed_size.x = maxf(0, value.x)
	_windowed_size.y = maxf(0, value.y)


func is_windowed_maximized() -> bool:
	return _windowed_maximized


func set_windowed_maximized(value: bool) -> void:
	_windowed_maximized = value
	save_settings()


# Settings: Files

func get_last_opened_folder() -> String:
	return _last_opened_folder


func set_last_opened_folder(value: String) -> void:
	_last_opened_folder = value
	save_settings()
