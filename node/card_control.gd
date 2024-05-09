extends Control



# setting parent

var parent: Cardlike

func _ready():
	parent = get_parent().get_parent()
	
	# signals
	parent.flipped_changed.connect(on_flipped)
	parent.mouse_entered.connect(set_outline.bind(true))
	parent.mouse_exited.connect(set_outline.bind(false))
	parent.drag_started.connect(set_default_cursor_shape.bind(CURSOR_DRAG))
	parent.drag_ended.connect(set_default_cursor_shape.bind(CURSOR_CAN_DROP))
	parent.tree_exited.connect(set_outline.bind(false))
	
	# setting card
	if parent is Card:
		card = parent
	elif parent is Cardlist:
		if parent.size(): card = parent.top()
		
		# list signals
		parent.cards_changed.connect(on_list_cards_changed)
		parent.rotation_changed.connect(update_list_border)
		
		update_list_border()
	
	update_side()



# input toggling

var pickable: bool:
	set(value): mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	get: return mouse_filter == Control.MOUSE_FILTER_STOP



# card

var card: Card:
	set(value):
		card = value
		
		for key: String in card_connections:
			card[key].connect(card_connections[key])
		
		on_renamed()

var card_connections: Dictionary = {
	"renamed": on_renamed,
}



# parent

func set_outline(value: bool):
	$Outline.visible = value

func on_flipped():
	$Animator.play("flip")
	await $Animator.animation_finished
	update_side()
	$Animator.play_backwards("flip")

func update_side():
	$Sides.current_tab = int(parent.flipped)
	update_tooltip()



# card

func on_renamed():
	$Sides/Front/Name.text = card.card_name
	update_tooltip()

func update_tooltip():
	tooltip_text = card.card_name if not card.flipped else ""
	if parent is Cardlist:
		tooltip_text += " (" + var_to_str(parent.size()) + " cards)"



# list

var panel: StyleBoxFlat = get_theme_stylebox("panel")
var bottom_side: String = "bottom"

func on_list_cards_changed():
	if card:
		for key: String in card_connections:
			card[key].disconnect(card_connections[key])
	if parent.size(): card = parent.top()
	
	panel["border_width_" + bottom_side] = parent.size()

func update_list_border():
	panel["border_width_" + bottom_side] = 0
	bottom_side = ["bottom", "right", "top", "left"][parent.rotation_degrees / 90]
	panel["border_width_" + bottom_side] = parent.size()
