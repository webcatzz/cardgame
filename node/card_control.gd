extends Control



func _ready():
	set_parent(get_parent().get_parent())

func set_parent(cardlike: Cardlike):
	parent = cardlike



# input toggling

var pickable: bool:
	set(value): mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	get: return mouse_filter == Control.MOUSE_FILTER_STOP



# signals

var connections: Dictionary = {
	"parent": {
		"flipped_changed": on_flipped,
		
		"mouse_entered": set_outline.bind(true),
		"mouse_exited": set_outline.bind(false),
		"tree_exited": set_outline.bind(false),
		
		"drag_started": set_default_cursor_shape.bind(Control.CURSOR_DRAG),
		"drag_ended": set_default_cursor_shape.bind(Control.CURSOR_CAN_DROP),
		
		"replacing_by": set_parent,
	},
	
	"card": {
		"renamed": on_renamed,
	},
	
	"list": {
		"cards_changed": on_list_cards_changed,
		"rotation_changed": update_list_border,
	},
}

func connect_as(key: String, cardlike: Cardlike):
	for signl: String in connections[key]:
		cardlike[signl].connect(connections[key][signl])

func disconnect_as(key: String, cardlike: Cardlike):
	for signl: String in connections[key]:
		cardlike[signl].disconnect(connections[key][signl])

func disconnect_all():
	var valid_signals: PackedStringArray = connections.parent.keys() + connections.card.keys() + connections.list.keys()
	for connection: Dictionary in get_incoming_connections():
		if connection.signal.get_name() in valid_signals:
			connection.signal.disconnect(connection.callable)



# setting nodes

var parent: Cardlike:
	set(value):
		parent = value
		
		disconnect_all()
		connect_as("parent", parent)
		
		if parent is Card: card = parent
		elif parent is Cardlist:
			if parent.size(): card = parent.top()
			connect_as("list", parent)
			update_list_border()
		
		update_side()

var card: Card:
	set(value):
		card = value
		connect_as("card", card)
		
		on_renamed()



# node

func set_outline(value: bool):
	$Outline.visible = value

func on_flipped():
	$Animator.play("flip")
	await $Animator.animation_finished
	update_side()
	$Animator.play_backwards("flip")

func update_side():
	$Sides.current_tab = int(parent.flipped)



# card

func on_renamed():
	$Sides/Front/Name.text = card.card_name
	tooltip_text = card.card_name
	if parent is Cardlist: tooltip_text += " (" + var_to_str(parent.size()) + " cards)"



# list

var panel: StyleBoxFlat = get_theme_stylebox("panel")
var bottom_side: String = "bottom"

func on_list_cards_changed():
	disconnect_as("card", card)
	if parent.size(): card = parent.top()
	panel["border_width_" + bottom_side] = parent.size()

func update_list_border():
	panel["border_width_" + bottom_side] = 0
	bottom_side = ["bottom", "right", "top", "left"][parent.rotation_degrees / 90]
	panel["border_width_" + bottom_side] = parent.size()
