###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name GlowButton extends Button

const VIGNETTE_OFF_INTENSITY := 0.4
const VIGNETTE_FADE_DURATION := 0.05
const TOGGLE_FADE_DURATION := 0.15

enum ButtonStyle {
	NORMAL,
	SHALLOW,
}

const STYLE_PRESETS := {
	ButtonStyle.NORMAL: [ 2.05 ],
	ButtonStyle.SHALLOW: [ 1.05 ],
}

@export var off_color: Color = Color(0.2, 0.2, 0.2):
	set = set_off_color
@export var on_color: Color = Color(0.6, 0.6, 0.6):
	set = set_on_color
@export var force_glow: bool = false:
	set = set_force_glow

@export var style_preset: ButtonStyle = ButtonStyle.NORMAL:
	set = set_style_preset

# Animated properties.

var _vignette_intensity: float = VIGNETTE_OFF_INTENSITY
var _label_intensity: float = 0.0
var _panel_main_color: Color = Color()
var _panel_back_color: Color = Color()

var _vignette_tweener: Tween = null
var _toggle_tweener: Tween = null

@onready var _panel: Panel = %Panel
@onready var _label: Label = %Label
@onready var _icon: TextureRect = %Icon


func _ready() -> void:
	_update_text(text)
	_update_icon(icon)
	_update_label_color()
	_update_icon_color()
	_setup_animated_properties()

	button_down.connect(_animate_button_held.bind(true))
	button_up.connect(_animate_button_held.bind(false))
	resized.connect(_update_shader_size)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_update_label_color()
		_update_icon_color()
		_setup_animated_properties()
	elif what == NOTIFICATION_EDITOR_PRE_SAVE:
		_clear_label_color()
		_clear_icon_color()
	elif what == NOTIFICATION_EDITOR_POST_SAVE:
		_update_label_color()
		_update_icon_color()


# Hook into the setter to propagate properties rendered with extra nodes.
func _set(property_name: StringName, value: Variant) -> bool:
	if property_name == "text":
		_update_text(value)
	elif property_name == "icon":
		_update_icon(value)

	return false


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


func set_force_glow(value: bool) -> void:
	if force_glow == value:
		return

	force_glow = value

	_setup_label_intensity()
	_update_label_intensity(_label_intensity)
	_update_label_color()
	_update_icon_color()

	_setup_panel_colors()
	_update_panel_main_color(_panel_main_color)
	_update_panel_back_color(_panel_back_color)


func set_style_preset(value: ButtonStyle) -> void:
	if style_preset == value:
		return

	style_preset = value
	_update_shader_style()


# Animation.

func _setup_animated_properties() -> void:
	_vignette_intensity = VIGNETTE_OFF_INTENSITY

	_setup_label_intensity()
	_setup_panel_colors()
	_update_all_shaders()


func _setup_label_intensity() -> void:
	var on_label_intensity := get_theme_constant("on_label_intensity") / 100.0

	_label_intensity = on_label_intensity if button_pressed else 0.0
	if force_glow:
		_label_intensity = on_label_intensity


func _setup_panel_colors() -> void:
	var off_back_color := get_theme_color("off_back_color")

	_panel_main_color = on_color if button_pressed else off_color
	_panel_back_color = off_color if button_pressed else off_back_color
	if force_glow:
		_panel_main_color = on_color
		_panel_back_color = off_color


func _animate_button_held(is_down: bool) -> void:
	if is_instance_valid(_vignette_tweener):
		_vignette_tweener.kill()

	_vignette_tweener = create_tween()

	var target_value := 1.0 if is_down else VIGNETTE_OFF_INTENSITY
	_vignette_tweener.tween_method(_update_vignette_intensity, _vignette_intensity, target_value, VIGNETTE_FADE_DURATION)


func _animate_button_toggled() -> void:
	if not is_inside_tree():
		return

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
	_toggle_tweener.tween_callback(_update_icon_color)


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
	(_icon.material as ShaderMaterial).set_shader_parameter("intensity", _label_intensity)


func _update_shader_style() -> void:
	if not is_node_ready():
		return

	var active_style: Array = STYLE_PRESETS[style_preset]
	(_panel.material as ShaderMaterial).set_shader_parameter("horizontal_incline", active_style[0])


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

	_update_shader_style()
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
	elif force_glow:
		label_color = on_font_color

	_label.add_theme_color_override("font_color", label_color)
	_label.add_theme_font_override("font", get_theme_font("font"))
	_label.add_theme_font_size_override("font_size", get_theme_font_size("font_size"))


func _clear_label_color() -> void:
	if not is_node_ready():
		return

	_label.remove_theme_color_override("font_color")
	_label.remove_theme_font_override("font")
	_label.remove_theme_font_size_override("font_size")


func _update_text(value: String) -> void:
	if not is_node_ready():
		return

	_label.text = value


# Icon properties.

func _update_icon_color() -> void:
	if not is_node_ready():
		return

	var default_font_color := get_theme_color("font_normal_color")
	var on_font_color := get_theme_color("font_pressed_color")
	var off_font_color := get_theme_color("font_color")

	var icon_color := default_font_color
	if toggle_mode:
		icon_color = on_font_color if button_pressed else off_font_color
	elif force_glow:
		icon_color = on_font_color

	_icon.self_modulate = icon_color


func _clear_icon_color() -> void:
	if not is_node_ready():
		return

	_icon.self_modulate = Color.WHITE


func _update_icon(value: Texture2D) -> void:
	if not is_node_ready():
		return

	var style := get_theme_stylebox("normal")

	_icon.texture = value
	_icon.offset_left = style.content_margin_left
	_icon.offset_top = style.content_margin_top
	_icon.offset_right = -style.content_margin_right
	_icon.offset_bottom = -style.content_margin_bottom
