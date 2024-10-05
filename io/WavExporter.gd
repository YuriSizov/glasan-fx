###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name WavExporter extends RefCounted

const FILE_EXTENSION := "wav"

enum FormatChunkSize {
	FMT_16 = 16,
	FMT_18 = 18,
	FMT_40 = 40,
}

# Note, this is for completeness; only WAVE_FORMAT_PCM is currently supported.
enum WaveFormat {
	WAVE_FORMAT_PCM = 0x0001,        # PCM
	WAVE_FORMAT_IEEE_FLOAT = 0x0003, # IEEE float
	WAVE_FORMAT_ALAW = 0x0006,       # 8-bit ITU-T G.711 A-law
	WAVE_FORMAT_MULAW = 0x0007,      # 8-bit ITU-T G.711 µ-law
	WAVE_FORMAT_EXTENSIBLE = 0xFFFE, # Determined by SubFormat
}

const INT16_MAX := 32767

static var _fmt_chunk_size: int = FormatChunkSize.FMT_16
static var _wave_format: int = WaveFormat.WAVE_FORMAT_PCM
static var _channel_number: int = 2
static var _sampling_rate: int = 44100
static var _bits_per_sample: int = 16


static func export(path: String) -> bool:
	if path.get_extension() != FILE_EXTENSION:
		printerr("WavExporter: The waveform file must have a .%s extension." % [ FILE_EXTENSION ])
		return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	var error := FileAccess.get_open_error()
	if error != OK:
		printerr("WavExporter: Failed to open the file at '%s' for writing (code %d)." % [ path, error ])
		return false

	var file_buffer := _write_file()
	if file_buffer.is_empty():
		printerr("WavExporter: Failed to generate the file at '%s'." % [ path ])
		return false

	# Try to write the file with the new contents.

	file.store_buffer(file_buffer)
	error = file.get_error()
	if error != OK:
		printerr("WavExporter: Failed to write to the file at '%s' (code %d)." % [ path, error ])
		return false

	return true


static func _write_file() -> PackedByteArray:
	var buffer := PackedByteArray()
	var data_buffer := PackedByteArray()

	var sample_params := Controller.voice_manager.get_sample_params()
	if not sample_params:
		return buffer

	var voice_params := Controller.voice_manager.get_voice_params()
	if not voice_params || not voice_params.voice:
		return buffer

	# Render the sample and convert the wave data.

	var note_octave := Note.get_note_octave(sample_params.note.value)
	var note_literal := Note.get_note_mml(sample_params.note.value)

	var sample_mml := ""
	sample_mml += voice_params.voice.get_mml(0) + "\n"
	sample_mml += "%%6@0 o%d%s;" % [ note_octave, note_literal ]

	var sample_length := sample_params.length.value
	var sample_buffer := Controller.voice_manager.render_sample(sample_mml, sample_length)
	for sample_value in sample_buffer:
		var offset := data_buffer.size()
		data_buffer.resize(offset + 2)
		data_buffer.encode_s16(offset, int(sample_value * INT16_MAX))

	# Calculate the total size.

	var total_size := 0
	total_size += 4 # WAVE literal length.
	total_size += _fmt_chunk_size + 8 # fmt chunk length, 4 + 4 for the chunk header.
	total_size += data_buffer.size() + 8 # data chunk length, 4 + 4 for the chunk header.

	# Write the header.

	ByteArrayUtil.write_string(buffer, "RIFF") # WAV is a RIFF document.
	ByteArrayUtil.write_int32(buffer, total_size)
	ByteArrayUtil.write_string(buffer, "WAVE") # Wave file description.

	# Write the format chunk.

	ByteArrayUtil.write_string(buffer, "fmt ")
	ByteArrayUtil.write_int32(buffer, _fmt_chunk_size)

	# WAVE_FORMAT_PCM format is assumed here.
	ByteArrayUtil.write_int16(buffer, _wave_format)
	ByteArrayUtil.write_int16(buffer, _channel_number)
	ByteArrayUtil.write_int32(buffer, _sampling_rate)
	@warning_ignore("integer_division")
	ByteArrayUtil.write_int32(buffer, (_sampling_rate * _channel_number * _bits_per_sample) / 8) # Data rate (bytes/sec).
	@warning_ignore("integer_division")
	ByteArrayUtil.write_int16(buffer, (_channel_number * _bits_per_sample) / 8) # Data block alignment.
	ByteArrayUtil.write_int16(buffer, _bits_per_sample)

	# Write the data chunk.

	ByteArrayUtil.write_string(buffer, "data")
	ByteArrayUtil.write_int32(buffer, data_buffer.size())

	buffer.append_array(data_buffer)
	# If data size is odd, a padding byte should be added. But it cannot be odd in our case.

	return buffer
