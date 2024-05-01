class_name Deck extends Cardlist



func _ready():
	super()
	
	var control: Control = card_control.instantiate()
	add_child(control)
	click_area = control.get_child(0)
	
	card_removed.connect(cardify_if_size_1.unbind(1))



# card conversion

func cardify_if_size_1():
	if size() == 1: replace_with(remove_top())



# splitting

func split() -> Cardlist:
	var list: Cardlist = super()
	var deck: Deck = Deck.new()
	
	deck.add(list)
	
	deck.orient(self)
	deck.position = position + Vector2(110, -10)
	
	Game.table.add_child(deck)
	await deck.move_to(deck.position + Vector2(0, 10))
	deck.cardify_if_size_1()
	
	return deck
