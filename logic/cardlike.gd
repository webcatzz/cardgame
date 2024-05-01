class_name Cardlike extends GameObject



# flipping

signal flipped_changed

var flipped: bool = false:
	set(value):
		var oldValue: bool = flipped
		flipped = value
		if not flipped == oldValue: flipped_changed.emit()

func flip():
	flipped = !flipped



# art

var front_art: Texture2D
var back_art: Texture2D

func get_art():
	return back_art if flipped else front_art



# snapping to cardlists

static var snap_point_scene: PackedScene = load("res://node/snap_point.tscn")

var snap_point: Area2D = snap_point_scene.instantiate()

var snappable: bool = true:
	set(value):
		snappable = value
		snap_point.monitoring = value
		snap_point.monitorable = value

func _ready():
	add_child(snap_point)
	drag_ended.connect(stack_with_nearby)

func stack_with_nearby():
	if not snappable: return
	for area: Area2D in snap_point.get_overlapping_areas():
		var node: Node = area.get_parent()
		if node is Cardlike: node.stack(self)
		elif node.name == "Hand": node.hand.add(self)

func stack(node: Cardlike):
	pass # overwritten by child classes



# tree

func orient(game_object: GameObject):
	if game_object is Cardlike:
		game_object.flipped = flipped
	super(game_object)


# card control

static var card_control: PackedScene = load("res://node/card_control.tscn")



# key events

func key_event(event: InputEvent):
	super(event)
	if not get_viewport().is_input_handled():
		if event.is_action_pressed("flip"):
			click_area.accept_event()
			flip()



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Flip", "click": flip},
		{"type": "separator"}
	] + super()
