###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name GlowButton extends Button

@export var off_color: Color = Color("3b0201")
@export var on_color: Color = Color("b93026")

@onready var _panel: Panel = %Panel
@onready var _label: Label = %Label


func _ready() -> void:
	_update_shaders()

	button_down.connect(func() -> void:
		(_panel.material as ShaderMaterial).set_shader_parameter("vignette_intensity", 1.0)
	)
	button_up.connect(func() -> void:
		(_panel.material as ShaderMaterial).set_shader_parameter("vignette_intensity", 0.0)
	)


func _toggled(_toggled_on: bool) -> void:
	_update_shaders()


func _update_shaders() -> void:
	var main_color := on_color if button_pressed else off_color
	var back_color := off_color if button_pressed else Color("000000")
	(_panel.material as ShaderMaterial).set_shader_parameter("main_color", main_color)
	(_panel.material as ShaderMaterial).set_shader_parameter("back_color", back_color)

	var label_color := Color("ffffff") if button_pressed else Color("a0a0a0")
	_label.add_theme_color_override("font_color", label_color)
	var label_intensity := 0.65 if button_pressed else 0.0
	(_label.material as ShaderMaterial).set_shader_parameter("intensity", label_intensity)
