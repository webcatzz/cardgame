class_name Deck extends Cardlist



func _ready():
	var control: Control = preload("res://node/card_control.tscn").instantiate()
	setup_click_area(control.get_child(0))
	add_child(control)
	super()
	
	card_removed.connect(cardify_if_size_1.unbind(1))



# card conversion

func cardify():
	var card: Card = remove_top()
	get_parent().add_child(card)
	queue_free()
	card.position = position
	return card

func cardify_if_size_1():
	if size() == 1: cardify()



# splitting

func split() -> Cardlist:
	var list: Cardlist = super()
	var deck: Deck = Deck.new()
	
	Game.table.add_child(deck)
	deck.position = position
	deck.move_to(position + Vector2(110, 0))
	deck.add(list)
	deck.cardify_if_size_1()
	
	return deck
