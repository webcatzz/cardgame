extends Control


var hand: Cardlist

@onready var hbox: HBoxContainer = $HBox


func _ready():
	hand = Game.you.hand
	hand.card_added.connect(on_card_added)
	hand.card_removed.connect(on_card_removed)
	for card in hand.cards:
		on_card_added(card)
	
	get_viewport().size_changed.connect(set_snap_width)
	set_snap_width()

func set_snap_width():
	$Snap/Shape.shape.size.x = get_viewport().get_visible_rect().size.x



# displaying cards in hand

func on_card_removed(card: Card):
	for node: Control in hbox.get_children():
		if node.get_child(0) == card:
			node.queue_free()
			break

func on_card_added(card: Card):
	var control: Control = Control.new()
	control.add_child(card)
	hbox.add_child(control)
	card.snappable = false
	
	# removing by drag
	card.drag_ended.connect(on_card_drag_ended.bind(card))

func on_card_drag_ended(card: Card):
	card.snappable = true
	await Game.wait_for_the_engine_to_stop_being_silly()
	if card.snap_point.overlaps_area($Snap):
		card.snappable = false
		card.position = Vector2.ZERO
	else:
		card.drag_ended.disconnect(on_card_drag_ended)
		hand.remove(card)
		card.reparent(Game.table)
		await Game.wait_for_the_engine_to_stop_being_silly()
		card.stack_with_nearby()
