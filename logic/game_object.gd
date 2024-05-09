class_name GameObject extends Node2D



# tree

func replace_with(game_object: GameObject, free: bool = true):
	game_object.orient(self)
	add_sibling(game_object)
	if free: queue_free()
	else: remove_from_tree()

func orient(game_object: GameObject):
	position = game_object.position
	rotation = game_object.rotation
	z_index = game_object.z_index

func remove_from_tree():
	if get_parent(): get_parent().remove_child(self)



# click area

var click_area: Control:
	set(value):
		click_area = value
		click_area.gui_input.connect(click_area_event)
		# mouse events
		click_area.mouse_entered.connect(emit_if_not_grabbed.bind(mouse_entered))
		click_area.mouse_exited.connect(emit_if_not_grabbed.bind(mouse_exited))

func emit_if_not_grabbed(sig: Signal):
	if !grab: sig.emit()



# dragging

signal mouse_entered
signal mouse_exited
signal drag_started
signal drag_ended

var grab: Vector2 = Vector2.ZERO
static var z = 0

func click_area_event(event: InputEvent):
	if event is InputEventMouseButton:
		
		# starting/ending drag
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_area.accept_event()
			if event.pressed and not grab: start_drag(event)
			elif grab and not event.pressed: end_drag()
		
		# context menu
		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			click_area.accept_event()
			ContextMenu.new(event.global_position, get_context_menu_options())
	
	# dragging
	elif event is InputEventMouseMotion and grab:
		click_area.accept_event()
		drag(event)

func start_drag(event: InputEventMouseButton):
	grab = event.global_position - global_position
	GameObject.z += 1
	z_index = GameObject.z
	drag_started.emit()

func drag(event: InputEventMouseMotion):
	global_position = event.global_position - grab

func end_drag():
	grab = Vector2.ZERO
	drag_ended.emit()




# smoothing

func move_to(pos: Vector2):
	click_area.pickable = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, 0.1)
	await tween.finished
	
	click_area.pickable = true

signal rotation_changed

func rotate_to(rot: float):
	click_area.pickable = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "rotation_degrees", rot, 0.1)
	await tween.finished
	
	if rotation_degrees < 0: rotation_degrees = 360 + rotation_degrees
	elif rotation_degrees >= 360: rotation_degrees = rotation_degrees - 360
	rotation_changed.emit()
	
	click_area.pickable = true



# key events

func _unhandled_key_input(event: InputEvent):
	if click_area.pickable and Rect2(Vector2.ZERO, click_area.size).has_point(click_area.get_local_mouse_position()):
		key_event(event)

func key_event(event: InputEvent):
	if event.is_action_released("rotate_left"):
		click_area.accept_event()
		rotate_to(rotation_degrees - 90)
	elif event.is_action_released("rotate_right"):
		click_area.accept_event()
		rotate_to(rotation_degrees + 90)



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Remove", "click": queue_free}
	]
