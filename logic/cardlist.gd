class_name Cardlist extends Cardlike



# cards array

signal cards_changed
signal card_added(card: Card)
signal card_removed(card: Card)

var cards: Array[Card] = []

@export var names: PackedStringArray:
	set(value):
		for card_name in value:
			add(Card.new(card_name), false)

func _ready():
	super()
	flipped_changed.connect(on_flipped_changed)



# adding

func add(card: Cardlike, remove: bool = true) -> Card:
	if remove: card.remove_from_tree()
	card.orient(self)
	card.position = Vector2.ZERO
	
	if card is Card:
		cards.append(card)
		card_added.emit(card)
	elif card is Cardlist:
		cards.append_array(card.cards)
		for c in card.cards: card_added.emit(c)
	
	cards_changed.emit()
	return card

func add_bottom(card: Cardlike) -> Card:
	card.remove_from_tree()
	card.orient(self)
	card.position = Vector2.ZERO
	
	if card is Card:
		cards.push_front(card)
		card_added.emit(card)
	elif card is Cardlist:
		for c in card.cards:
			cards.push_front(card.cards)
			card_added.emit(c)
	
	cards_changed.emit()
	return card



# removing

func remove(card: Card) -> Card:
	cards.erase(card)
	cards_changed.emit()
	card_removed.emit(card)
	return card

func remove_at(idx: int) -> Card:
	var card: Card = cards.pop_at(-idx)
	cards_changed.emit()
	card_removed.emit(card)
	return card

func remove_top() -> Card:
	var card: Card = cards.pop_back()
	cards_changed.emit()
	card_removed.emit(card)
	return card



# ordering

func shuffle():
	cards.shuffle()
	cards_changed.emit()

func split() -> Cardlist:
	var half: int = size() / 2
	var taken: Array[Card] = cards.slice(half)
	cards.resize(half)
	
	var new_list: Cardlist = Cardlist.new()
	for card: Card in taken:
		new_list.add(card)
		card_removed.emit(card)
	
	cards_changed.emit()
	return new_list



# getters

func top() -> Card:
	return cards.back()

func at(idx: int) -> Card:
	return cards[-idx]

func size() -> int:
	return cards.size()



# hand interaction

func deal(amount: int = 1):
	for i in amount:
		for player in Game.players:
			player.hand.add(remove_top())

func draw(amount: int = 1):
	for i in amount:
		Game.you.hand.add(remove_top())



# flipping

func on_flipped_changed():
	cards.reverse()
	for card: Card in cards:
		card.flip()



# stacking

func stack(node: Cardlike):
	await super(node)
	add(node)



# events

func start_drag(event: InputEventMouseButton):
	if event.shift_pressed:
		var card: Card = remove_top()
		card.position = position
		add_sibling(card)
		card.click_area.grab_click_focus()
		card.mouse_entered.emit()
		card.start_drag(event)
	else:
		super(event)

func key_event(event: InputEvent):
	super(event)
	if not get_viewport().is_input_handled():
		if event.is_action_pressed("roll"):
			click_area.accept_event()
			shuffle()



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Draw", "click": draw},
		{"label": "Deal", "click": deal},
		{"label": "Shuffle", "click": shuffle},
		{"label": "Split", "click": split},
		{"type": "separator"}
	] + super()
