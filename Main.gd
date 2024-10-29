###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

extends MarginContainer

@onready var _menu_panel: MenuPanel = %MenuPanel
@onready var _main_view: Control = %MainView
@onready var _about_view: Control = %AboutView


func _enter_tree() -> void:
	Controller.window_manager.register_window()


func _ready() -> void:
	Controller.window_manager.restore_window()

	_setup_views()
	_menu_panel.about_toggled.connect(_toggle_views)


func _setup_views() -> void:
	_main_view.visible = true
	_about_view.visible = false


func _toggle_views() -> void:
	_main_view.visible = not _main_view.visible
	_about_view.visible = not _about_view.visible
