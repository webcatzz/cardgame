class_name Card extends Cardlike


var card_name: String



# loading from data

static var STORED: Dictionary = {
	"cards": DirAccess.get_files_at("res://data/card/"),
	"actors": DirAccess.get_files_at("res://data/card/actor/")
}

@export var data: String:
	set(value):
		load_data(data)

func data_path():
	return "res://data/card/"

func _init(card_name: String = ""):
	if card_name: load_data(card_name)
	else:
		TEMP += 1
		self.card_name = var_to_str(TEMP)

func load_data(card_name: String):
	var data: CardData = load(data_path() + card_name + ".tres")
	data.assign(self)



# control

static var TEMP: int = 0

func _ready():
	super()
	
	var control: Control = card_control.instantiate()
	add_child(control)
	click_area = control.get_child(0)



# deck conversion

func deckify() -> Deck:
	var deck: Deck = Deck.new()
	
	var pos: Vector2 = position
	deck.add(self, false)
	replace_with(deck, false)
	deck.position = pos
	
	return deck

func stack(node: Cardlike):
	await node.move_to(position)
	var deck: Deck = deckify()
	deck.add(node)



# context menu

func get_context_menu_options() -> Array:
	return [
		{"label": "Add to hand", "click": func(): Game.you.hand.add(self)},
		{"type": "separator"}
	] + super()
