###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name StyleTexture extends Texture2D

@export var stylebox: StyleBox = null:
	set = set_stylebox
@export var width: int = 20:
	set = set_width
@export var height: int = 20:
	set = set_height


func _draw(to_canvas_item: RID, pos: Vector2, _modulate: Color, _transpose: bool) -> void:
	if not stylebox:
		return

	var rect := Rect2()
	rect.position = pos
	rect.size = Vector2(width, height)

	stylebox.draw(to_canvas_item, rect)


func _draw_rect(to_canvas_item: RID, rect: Rect2, _tile: bool, _modulate: Color, _transpose: bool) -> void:
	if not stylebox:
		return

	stylebox.draw(to_canvas_item, rect)


func _draw_rect_region(to_canvas_item: RID, rect: Rect2, _src_rect: Rect2, _modulate: Color, _transpose: bool, _clip_uv: bool) -> void:
	if not stylebox:
		return

	stylebox.draw(to_canvas_item, rect)


func set_stylebox(value: StyleBox) -> void:
	if stylebox == value:
		return

	if stylebox:
		stylebox.changed.disconnect(emit_changed)

	stylebox = value

	if stylebox:
		stylebox.changed.connect(emit_changed)


func set_width(value: int) -> void:
	if width == value:
		return

	width = value
	emit_changed()


func set_height(value: int) -> void:
	if height == value:
		return

	height = value
	emit_changed()


func _get_width() -> int:
	return width


func _get_height() -> int:
	return height
