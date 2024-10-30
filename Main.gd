###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends MarginContainer

enum View {
	MAIN,
	SETTINGS,
	ABOUT,
}

var _current_view: View = View.MAIN

@onready var _menu_panel: MenuPanel = %MenuPanel
@onready var _main_view: Control = %MainView
@onready var _settings_view: Control = %SettingsView
@onready var _about_view: Control = %AboutView


func _enter_tree() -> void:
	Controller.window_manager.register_window()


func _ready() -> void:
	Controller.window_manager.restore_window()

	_setup_views()
	_menu_panel.settings_toggled.connect(_toggle_views.bind(View.SETTINGS))
	_menu_panel.about_toggled.connect(_toggle_views.bind(View.ABOUT))


func _setup_views() -> void:
	_current_view = View.MAIN
	_update_views()


func _toggle_views(next_view: View) -> void:
	if _current_view == next_view:
		_current_view = View.MAIN
	else:
		_current_view = next_view

	_update_views()


func _update_views() -> void:
	_main_view.visible = (_current_view == View.MAIN)
	_settings_view.visible = (_current_view == View.SETTINGS)
	_about_view.visible = (_current_view == View.ABOUT)
