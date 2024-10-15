###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name GlowButton extends Button

const VIGNETTE_FADE_DURATION := 0.05
const TOGGLE_FADE_DURATION := 0.15

@export var off_color: Color = Color("3b0201"):
	set = set_off_color
@export var on_color: Color = Color("b93026"):
	set = set_on_color

# Animated properties.

var _vignette_intensity: float = 0.0
var _label_intensity: float = 0.0
var _panel_main_color: Color = Color()
var _panel_back_color: Color = Color()

var _vignette_tweener: Tween = null
var _toggle_tweener: Tween = null

@onready var _panel: Panel = %Panel
@onready var _label: Label = %Label


func _ready() -> void:
	_update_text()
	_update_label_color()
	_setup_animated_properties()

	button_down.connect(_animate_button_held.bind(true))
	button_up.connect(_animate_button_held.bind(false))
	resized.connect(_update_shader_size)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_label_color()
		_update_all_shaders()
	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_clear_label_color()
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_label_color()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_text()


func _toggled(_toggled_on: bool) -> void:
	_animate_button_toggled()


# Properties.

func set_off_color(value: Color) -> void:
	if off_color == value:
		return

	off_color = value
	_setup_panel_colors()
	_update_panel_main_color(_panel_main_color)
	_update_panel_back_color(_panel_back_color)


func set_on_color(value: Color) -> void:
	if on_color == value:
		return

	on_color = value
	_setup_panel_colors()
	_update_panel_main_color(_panel_main_color)
	_update_panel_back_color(_panel_back_color)


# Animation.

func _setup_animated_properties() -> void:
	var on_label_intensity := get_theme_constant("on_label_intensity") / 100.0

	_vignette_intensity = 0.0 # Always 0 by default because it's only visible when the button is held down.
	_label_intensity = on_label_intensity if button_pressed else 0.0

	_setup_panel_colors()
	_update_all_shaders()


func _setup_panel_colors() -> void:
	var off_back_color := get_theme_color("off_back_color")

	_panel_main_color = on_color if button_pressed else off_color
	_panel_back_color = off_color if button_pressed else off_back_color


func _animate_button_held(is_down: bool) -> void:
	if is_instance_valid(_vignette_tweener):
		_vignette_tweener.kill()

	_vignette_tweener = create_tween()

	var target_value := 1.0 if is_down else 0.0
	_vignette_tweener.tween_method(_update_vignette_intensity, _vignette_intensity, target_value, VIGNETTE_FADE_DURATION)


func _animate_button_toggled() -> void:
	if is_instance_valid(_toggle_tweener):
		_toggle_tweener.kill()

	_toggle_tweener = create_tween()
	_toggle_tweener.set_parallel(true)

	var off_back_color := get_theme_color("off_back_color")
	var on_label_intensity := get_theme_constant("on_label_intensity") / 100.0

	var main_color := on_color if button_pressed else off_color
	var back_color := off_color if button_pressed else off_back_color
	var label_intensity := on_label_intensity if button_pressed else 0.0

	_toggle_tweener.tween_method(_update_panel_main_color, _panel_main_color, main_color, TOGGLE_FADE_DURATION)
	_toggle_tweener.tween_method(_update_panel_back_color, _panel_back_color, back_color, TOGGLE_FADE_DURATION)
	_toggle_tweener.tween_method(_update_label_intensity, _label_intensity, label_intensity, TOGGLE_FADE_DURATION)

	_toggle_tweener.tween_callback(_update_label_color)


# Shader properties.

func _update_vignette_intensity(value: float) -> void:
	if not is_node_ready():
		return

	_vignette_intensity = value
	(_panel.material as ShaderMaterial).set_shader_parameter("vignette_intensity", _vignette_intensity)


func _update_panel_main_color(value: Color) -> void:
	if not is_node_ready():
		return

	_panel_main_color = value
	(_panel.material as ShaderMaterial).set_shader_parameter("main_color", _panel_main_color)


func _update_panel_back_color(value: Color) -> void:
	if not is_node_ready():
		return

	_panel_back_color = value
	(_panel.material as ShaderMaterial).set_shader_parameter("back_color", _panel_back_color)


func _update_label_intensity(value: float) -> void:
	if not is_node_ready():
		return

	_label_intensity = value
	(_label.material as ShaderMaterial).set_shader_parameter("intensity", _label_intensity)


func _update_shader_size() -> void:
	if not is_node_ready():
		return

	(_panel.material as ShaderMaterial).set_shader_parameter("button_size", size)


func _update_all_shaders() -> void:
	if not is_node_ready():
		return

	_update_vignette_intensity(_vignette_intensity)
	_update_panel_main_color(_panel_main_color)
	_update_panel_back_color(_panel_back_color)
	_update_label_intensity(_label_intensity)

	_update_shader_size()


# Label properties.

func _update_label_color() -> void:
	if not is_node_ready():
		return

	var default_font_color := get_theme_color("font_normal_color")
	var on_font_color := get_theme_color("font_pressed_color")
	var off_font_color := get_theme_color("font_color")

	var label_color := default_font_color
	if toggle_mode:
		label_color = on_font_color if button_pressed else off_font_color

	_label.add_theme_color_override("font_color", label_color)


func _clear_label_color() -> void:
	if not is_node_ready():
		return

	_label.remove_theme_color_override("font_color")


func _update_text() -> void:
	if not is_node_ready():
		return

	_label.text = text