class_name Cardlike extends GameObject



# flipping

signal flipped_changed

var flipped: bool = false:
	set(value):
		flipped = value
		flipped_changed.emit()

func flip():
	flipped = !flipped



# art

var front_art: Texture2D
var back_art: Texture2D

func get_art():
	return back_art if flipped else front_art



# inheriting style

func orient_to(cardlike: Cardlike):
	flipped = cardlike.flipped
	rotation = cardlike.rotation
	position = Vector2.ZERO
	z_index = 0



# snapping to cardlists

static var snap_point_scene: PackedScene = preload("res://node/snap_point.tscn")

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

func move_to(pos: Vector2):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, 0.1)
	await tween.finished



# removing from tree

func remove_from_tree():
	if get_parent(): get_parent().remove_child(self)



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Flip", "click": flip},
		{"type": "separator"}
	] + super()
