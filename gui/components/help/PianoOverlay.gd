###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name PianoOverlay extends Control

@export var piano_container: PianoContainer = null:
	set = set_piano_container

var _shortcut_buffers: Array[TextLine] = []


func _ready() -> void:
	_update_shortcut_buffers()


func _draw() -> void:
	if not is_instance_valid(piano_container):
		return

	for i in _shortcut_buffers.size():
		var text_buffer := _shortcut_buffers[i]
		var text_color := PianoKey.LIGHT_COLOR if Note.is_note_sharp(i) else PianoKey.DARK_COLOR

		var key_rect := piano_container._valid_children[i].get_rect()
		var text_position := key_rect.position + Vector2(key_rect.size.x / 2.0, key_rect.size.y)
		text_position.x -= text_buffer.get_size().x / 2.0
		text_position.y -= text_buffer.get_size().y + 6.0

		text_buffer.draw(get_canvas_item(), text_position, text_color)


func _update_shortcut_buffers() -> void:
	_shortcut_buffers.clear()
	if not is_instance_valid(piano_container):
		return

	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")

	for i in piano_container.number_of_keys:
		var text_buffer := TextLine.new()
		var shortcut_name := &"glasan_play_key%d" % [ i ]
		var shortcut_text := ShortcutLine.get_action_as_string(shortcut_name)

		text_buffer.add_string(shortcut_text, font, font_size)
		_shortcut_buffers.push_back(text_buffer)

	queue_redraw()


func set_piano_container(value: PianoContainer) -> void:
	if piano_container == value:
		return

	piano_container = value
	_update_shortcut_buffers()
