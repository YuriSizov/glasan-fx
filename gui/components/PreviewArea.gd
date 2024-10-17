###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

@tool
class_name PreviewArea extends PanelContainer

const RENDER_SCALE := 0.95

enum PreviewStyle {
	PREVIEW_SPECTRUM,
	PREVIEW_WAVE,
}

var _render_size: Vector2 = Vector2.ZERO
var _preview_style: PreviewStyle = PreviewStyle.PREVIEW_SPECTRUM

# Spectrum previews.

const SPECTRUM_VU_COUNT := 24
const SPECTRUM_FREQ_MAX := 11050.0
const SPECTRUM_MIN_DB := 60.0
const SPECTRUM_BAR_SPACING := 4
const SPECTRUM_LOW_COLOR := Color.SEA_GREEN
const SPECTRUM_HIGH_COLOR := Color.ORANGE_RED
const SPECTRUM_LERP := 0.2

var _spectrum_heights: PackedFloat32Array = PackedFloat32Array()
var _spectrum_colors: PackedColorArray = PackedColorArray()

# Wave previews.

const WAVE_MAX_SAMPLES := 240
const WAVE_COLOR := Color.ORANGE_RED
const WAVE_REVEAL_STEP := 4.0

var _wave_revealed: float = 0.0
var _wave_data: PackedFloat64Array = PackedFloat64Array()
var _wave_next_data: PackedFloat64Array = PackedFloat64Array()


func _ready() -> void:
	_update_render_size()
	resized.connect(_update_render_size)

	_wave_data.resize(WAVE_MAX_SAMPLES)
	_wave_data.fill(0.5)
	_wave_next_data.resize(WAVE_MAX_SAMPLES)
	_wave_next_data.fill(0.5)

	if not Engine.is_editor_hint():
		Controller.voice_manager.sample_started.connect(_clear_wave)
		Controller.voice_manager.sample_stopped.connect(_reveal_wave)


func _process(delta: float) -> void:
	match _preview_style:
		PreviewStyle.PREVIEW_SPECTRUM:
			queue_redraw()

		PreviewStyle.PREVIEW_WAVE:
			if _wave_revealed < 1.0:
				_wave_revealed = clampf(_wave_revealed + WAVE_REVEAL_STEP * delta, 0.0, 1.0)
				queue_redraw()


func _draw() -> void:
	match _preview_style:
		PreviewStyle.PREVIEW_SPECTRUM:
			_draw_spectrum()

		PreviewStyle.PREVIEW_WAVE:
			_draw_wave()


func _update_render_size() -> void:
	_render_size = size * RENDER_SCALE


func change_preview_style(style: PreviewStyle) -> void:
	_preview_style = style
	queue_redraw()


# Spectrum previews.

func _draw_spectrum() -> void:
	var audio_spectrum: AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(0, 0)
	if not audio_spectrum:
		return

	var offset := (size - _render_size) / 2
	var w := _render_size.x / SPECTRUM_VU_COUNT
	var prev_hz := 0.0

	var new_heights := PackedFloat32Array()
	var new_colors := PackedColorArray()

	for i in range(1, SPECTRUM_VU_COUNT + 1):
		var hz := i * SPECTRUM_FREQ_MAX / SPECTRUM_VU_COUNT;

		var magnitude: float = audio_spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var height := _get_spectrum_height(i - 1, magnitude)
		var color := _get_spectrum_color(i - 1, height)

		@warning_ignore("integer_division")
		var top_bar_position := Vector2(
			offset.x + SPECTRUM_BAR_SPACING / 2 + w * (i - 1),
			offset.y + _render_size.y / 2.0 - height - SPECTRUM_BAR_SPACING / 2.0
		)
		var top_bar_size := Vector2(w - SPECTRUM_BAR_SPACING, height)

		var bar_rect := Rect2(top_bar_position, top_bar_size)
		draw_rect(bar_rect, color)
		bar_rect.position.y = offset.y + _render_size.y / 2.0 + SPECTRUM_BAR_SPACING / 2.0
		draw_rect(bar_rect, color.darkened(0.5))

		new_heights.push_back(height)
		new_colors.push_back(color)

		prev_hz = hz

	_spectrum_heights = new_heights
	_spectrum_colors = new_colors


func _get_spectrum_height(index: int, magnitude: float) -> float:
	var base_factor := clampf((SPECTRUM_MIN_DB + linear_to_db(magnitude)) / SPECTRUM_MIN_DB, 0.0, 1.0)
	var base_value: float = base_factor * _render_size.y / 2.0

	if _spectrum_heights.is_empty():
		return base_value

	return lerp(_spectrum_heights[index], base_value, SPECTRUM_LERP)


func _get_spectrum_color(index: int, value: float) -> Color:
	var low_value := 0
	var high_value := _render_size.y / 2.0
	var base_value := SPECTRUM_LOW_COLOR.lerp(SPECTRUM_HIGH_COLOR, (value - low_value) / (high_value - low_value))

	if _spectrum_colors.is_empty():
		return base_value

	return lerp(_spectrum_colors[index], base_value, SPECTRUM_LERP)


# Wave previews.

func _draw_wave() -> void:
	var offset := (size - _render_size) / 2
	var step := _render_size.x / _wave_data.size()

	var revealed_idx := floori(_wave_data.size() * _wave_revealed)
	for i in revealed_idx:
		_wave_data[i] = _wave_next_data[i]

	for i in _wave_data.size() - 1:
		var from_point := offset + Vector2(step * i,       _render_size.y * _wave_data[i])
		var to_point   := offset + Vector2(step * (i + 1), _render_size.y * _wave_data[i + 1])

		draw_line(from_point, to_point, WAVE_COLOR, 1.0, true)


func _clear_wave() -> void:
	if _preview_style != PreviewStyle.PREVIEW_WAVE:
		return

	_wave_revealed = 0.0
	_wave_next_data.fill(0.5)

	queue_redraw()


func _reveal_wave() -> void:
	if _preview_style != PreviewStyle.PREVIEW_WAVE:
		return

	_wave_revealed = 0.0
	_wave_data = _wave_next_data.duplicate()

	var sample_data := Controller.voice_manager.get_sample_data()
	for i in _wave_next_data.size():
		if i < sample_data.size():
			_wave_next_data[i] = sample_data[i] + 0.5
		else:
			_wave_next_data[i] = 0.5

	queue_redraw()
