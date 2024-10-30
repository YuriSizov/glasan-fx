###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name PianoContainer extends Container

signal key_pressed(key_index: int)

const KEY_SCENE := preload("res://gui/components/preview/PianoKey.tscn")

@export_range(0, 12, 1, "or_greater") var number_of_keys: int = 12:
	set = set_number_of_keys
@export_range(-1, 12, 1, "or_greater") var selected_key: int = -1:
	set = set_selected_key
@export var reset_keys: bool:
	set = set_reset_keys

var _valid_children: Array[Control] = []
var _light_children: Array[Control] = []
var _dark_children: Array[Control] = []

var _hovered_child: Control = null


func _ready() -> void:
	_update_keys()
	_update_selected_key()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_sort_children()

	elif what == NOTIFICATION_MOUSE_EXIT:
		if is_instance_valid(_hovered_child):
			_hovered_child.notification(NOTIFICATION_MOUSE_EXIT)
			_hovered_child = null


func _gui_input(event: InputEvent) -> void:
	# Propagate mouse events back to the children. Children themselves are set to ignore, because
	# their visual order doesn't match their tree order.

	if event is InputEventMouse:
		var mouse_position := (event as InputEventMouse).position

		# Dark keys overlap light keys, so check them first.
		for child_control in _dark_children:
			if child_control.get_rect().has_point(mouse_position):
				_pass_gui_input(child_control, event)
				return

		# Then check the light keys.
		for child_control in _light_children:
			if child_control.get_rect().has_point(mouse_position):
				_pass_gui_input(child_control, event)
				return


func _pass_gui_input(child_control: Control, event: InputEvent) -> void:
	# Trigger mouse enter/exit signals.
	if _hovered_child != child_control:
		if is_instance_valid(_hovered_child):
			_hovered_child.notification(NOTIFICATION_MOUSE_EXIT)

		_hovered_child = child_control
		_hovered_child.notification(NOTIFICATION_MOUSE_ENTER)

	# Trigger the input handler.

	child_control.gui_input.emit()

	# Avoid modifying the original event.
	var child_event := event.duplicate()
	if child_event is InputEventMouse:
		child_event.position -= child_control.position

	if child_control.has_method("_gui_input"):
		child_control._gui_input(child_event)


func _get_minimum_size() -> Vector2:
	var min_size := Vector2.ZERO
	var child_index := 0

	_valid_children.clear()
	_light_children.clear()
	_dark_children.clear()

	for child_node in get_children():
		if child_node is not Control:
			continue

		var child_control := child_node as Control
		if not child_control.visible || child_control.top_level:
			continue

		# Sharp/dark keys go between normal/light ones, they don't take space on their own.
		if not Note.is_note_sharp(child_index):
			var child_size := child_control.get_combined_minimum_size()
			min_size.x += child_size.x
			min_size.y = maxf(min_size.y, child_size.y)

			_light_children.push_back(child_control)
		else:
			_dark_children.push_back(child_control)

		_valid_children.push_back(child_control)
		child_index += 1

	return min_size


func _sort_children() -> void:
	var light_amount := _light_children.size()
	var child_size_light := Vector2(size.x / light_amount, size.y)
	var child_size_dark := Vector2(
		(size.x / light_amount) * 2.0 / 3.0,
		size.y * 3.0 / 5.0
	)

	var child_offset := Vector2.ZERO
	var child_index := 0

	for child_node in get_children():
		if child_node is not PianoKey:
			continue

		var key := child_node as PianoKey
		if not key.visible || key.top_level:
			continue

		var child_rect := Rect2()
		child_rect.size = child_size_light
		child_rect.position = child_offset

		if Note.is_note_sharp(child_index):
			child_rect.size = child_size_dark
			child_rect.position.x -= child_rect.size.x / 2.0

		# Give the last child the remainder.
		if child_index == (_valid_children.size() - 1):
			child_rect.size.x = size.x - child_offset.x

		fit_child_in_rect(key, child_rect)
		# Make sure that the lights are rendered behind the darks.
		key.show_behind_parent = not Note.is_note_sharp(child_index)

		# Update insets.
		key.inset_left = Note.is_note_sharp(child_index - 1)
		key.inset_right = Note.is_note_sharp(child_index + 1)

		if not Note.is_note_sharp(child_index):
			child_offset.x += floorf(child_rect.size.x)
		child_index += 1


# Key management.

func set_number_of_keys(value: int) -> void:
	if number_of_keys == value:
		return

	number_of_keys = value
	_update_keys()


func set_selected_key(value: int) -> void:
	if selected_key == value:
		return

	selected_key = value
	_update_selected_key()


func set_reset_keys(_value: bool) -> void:
	while get_child_count() > 0:
		var child_node := get_child(0)
		remove_child(child_node)
		child_node.queue_free()

	while get_child_count() < number_of_keys:
		var child_node := KEY_SCENE.instantiate()
		child_node.name = "Key%d" % [ get_child_count() ]
		add_child(child_node)
		child_node.owner = owner


func _update_keys() -> void:
	if not is_node_ready():
		return

	# Remove excess keys.
	while number_of_keys < get_child_count():
		var child_node := get_child(number_of_keys)
		remove_child(child_node)
		child_node.queue_free()

	# Add missing keys.
	while get_child_count() < number_of_keys:
		var child_node := KEY_SCENE.instantiate()
		child_node.name = "Key%d" % [ get_child_count() ]
		add_child(child_node)
		child_node.owner = owner

	for child_node in get_children():
		var key := child_node as PianoKey

		if not key.key_pressed.is_connected(_select_pressed_key.bind(key)):
			key.key_pressed.connect(_select_pressed_key.bind(key))


func _update_selected_key() -> void:
	if not is_node_ready():
		return

	for child_node in get_children():
		(child_node as PianoKey).selected = (selected_key == child_node.get_index())


func _select_pressed_key(key: PianoKey) -> void:
	key_pressed.emit(key.get_index())
