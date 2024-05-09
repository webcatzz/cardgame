class_name Deck extends Cardlist



func _ready():
	super()
	if size() == 0: printerr("Cardlist readied with 0 cards.")
	
	var control: Control = card_control.instantiate()
	add_child(control)
	click_area = control.get_child(0)
	
	cards_changed.connect(cardify_if_size_1)



# card conversion

func cardify_if_size_1() -> Cardlike:
	if size() == 1:
		var card: Card = remove_top()
		replace_with(card)
		return card
	return self



# splitting

func split() -> Cardlist:
	var list: Cardlist = super()
	var deck: Cardlike = Deck.new()
	
	deck.add(list)
	
	deck.orient(self)
	deck.position = position + Vector2(110, -10)
	
	deck = deck.cardify_if_size_1()
	add_sibling(deck)
	await deck.move_to(deck.position + Vector2(0, 10))
	
	return deck
