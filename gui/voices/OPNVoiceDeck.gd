###################################################
# Part of Glasan FX                               #
# Copyright (c) 2024 Yuri Sizov and contributors  #
# Provided under MIT                              #
###################################################

class_name OPNVoiceDeck extends BaseVoiceDeck

const OPERATOR_SCENE := preload("res://gui/voices/operators/OPNOperatorDeck.tscn")

var _instantiated_operators: Array[OPNOperatorDeck] = []

@onready var _randomize_button: Button = %RandomizeButton

@onready var _add_operator_button: Button = %AddOperatorButton
@onready var _remove_operator_button: Button = %RemOperatorButton
@onready var _operator_indicator: OperatorIndicator = %OperatorIndicator

@onready var _volume_knob: RollerKnob = %VolumeKnob
@onready var _feedback_knob: RollerKnob = %FeedbackKnob
@onready var _algorithm_knob: RollerKnob = %AlgorithmKnob

@onready var _operator_container: TabContainer = %Operators


func _init() -> void:
	for i in 4:
		var operator_deck = OPERATOR_SCENE.instantiate()
		operator_deck.name = [ "A", "B", "C", "D" ][i]
		_instantiated_operators.push_back(operator_deck)


func _ready() -> void:
	_update_knobs()
	voice_changed.connect(_update_knobs)

	_add_operator_button.pressed.connect(func() -> void:
		if voice:
			voice.add_operator()
	)
	_remove_operator_button.pressed.connect(func() -> void:
		if voice:
			voice.remove_operator()
	)
	_randomize_button.pressed.connect(func() -> void:
		if voice:
			voice.randomize_voice()
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for operator_deck in _instantiated_operators:
			if is_instance_valid(operator_deck) && not operator_deck.is_inside_tree():
				operator_deck.queue_free()


# Knob management.

func _update_knobs() -> void:
	if not is_inside_tree():
		return

	# General knobs.

	BaseVoiceDeck.setup_roller_knob(_volume_knob, voice.volume)

	# Channel knobs.

	var channel_data := voice.get_channel_data()
	BaseVoiceDeck.setup_roller_knob(_feedback_knob, channel_data[OPNVoice.ChannelParam.FB])
	BaseVoiceDeck.setup_roller_knob(_algorithm_knob, channel_data[OPNVoice.ChannelParam.AL])

	# Operator knobs.

	_operator_indicator.operator_count = voice.get_operator_count()

	var extra_index := voice.get_operator_count()
	while extra_index < _operator_container.get_child_count():
		var child_node := _operator_container.get_child(extra_index)
		_operator_container.remove_child(child_node)

	for i in voice.get_operator_count():
		var operator_deck: OPNOperatorDeck = null

		if i >= _operator_container.get_child_count():
			operator_deck = _instantiated_operators[i]
			_operator_container.add_child(operator_deck)
		else:
			operator_deck = _operator_container.get_child(i)

		operator_deck.operator_data = voice.get_operator_data(i)