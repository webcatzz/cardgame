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

func load_data(card_name: String):
	var data: CardData = load(data_path() + card_name + ".tres")
	data.assign(self)



# control

const control_scene: PackedScene = preload("res://node/card_control.tscn")

var pickable: bool:
	set(value): click_area.mouse_filter = Control.MOUSE_FILTER_STOP if value else Control.MOUSE_FILTER_IGNORE
	get: return click_area.mouse_filter == Control.MOUSE_FILTER_STOP

func _ready():
	var control: Control = control_scene.instantiate()
	setup_click_area(control.get_child(0))
	add_child(control)
	super()
	
	tree_exited.connect(control.set_outline.bind(false))



# deck conversion

func deckify():
	var deck: Deck = Deck.new()
	get_parent().add_child(deck)
	deck.position = position
	deck.add(self)
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
