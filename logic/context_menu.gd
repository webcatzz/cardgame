class_name ContextMenu extends PopupMenu


var items: Array


func _init(pos: Vector2, items: Array):
	self.items = items
	for item in items:
		if "type" in item and item.type == "separator": add_separator()
		else: add_item(item.label)
	
	Game.get_node("/root").add_child(self)
	index_pressed.connect(on_index_pressed)
	popup(Rect2i(pos, Vector2.ZERO))


func on_index_pressed(idx: int):
	items[idx].click.call()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		queue_free()
