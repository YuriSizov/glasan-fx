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
	# Ensure that the minimum size of the UI is respected and
	# the main window cannot go any lower.
	get_window().wrap_controls = true


func _ready() -> void:
	_setup_views()
	_menu_panel.about_toggled.connect(_toggle_views)


func _setup_views() -> void:
	_main_view.visible = true
	_about_view.visible = false


func _toggle_views() -> void:
	_main_view.visible = not _main_view.visible
	_about_view.visible = not _about_view.visible
