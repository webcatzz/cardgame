class_name GameObject extends Node2D



# click area

var click_area: Control

func setup_click_area(area: Node):
	click_area = area
	click_area.gui_input.connect(click_area_event)
	# mouse events
	click_area.mouse_entered.connect(emit_if_not_grabbed.bind(mouse_entered))
	click_area.mouse_exited.connect(emit_if_not_grabbed.bind(mouse_exited))
	# drag cursor
	drag_started.connect(click_area.set_default_cursor_shape.bind(Control.CURSOR_DRAG))
	drag_ended.connect(click_area.set_default_cursor_shape.bind(Control.CURSOR_CAN_DROP))

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
			get_viewport().set_input_as_handled()
			if event.pressed and not grab:
				grab = event.global_position - global_position
				GameObject.z += 1
				z_index = GameObject.z
				drag_started.emit()
			elif not event.pressed and grab:
				grab = Vector2.ZERO
				drag_ended.emit()
		
		# context menu
		elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
			get_viewport().set_input_as_handled()
			ContextMenu.new(event.global_position, get_context_menu_options())
	
	# dragging
	elif event is InputEventMouseMotion and grab:
		get_viewport().set_input_as_handled()
		global_position = event.global_position - grab



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Remove", "click": queue_free}
	]
