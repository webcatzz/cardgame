extends Control


var represents: Cardlike


func _ready():
	if not represents: represents = get_parent()
	
	# outline
	represents.mouse_entered.connect(set_outline.bind(true))
	represents.mouse_exited.connect(set_outline.bind(false))
	
	if represents is Deck:
		represents.cards_changed.connect(update_deck_height)
		update_deck_height()


func update_deck_height():
	$Container.get_theme_stylebox("panel").border_width_bottom = represents.size() - 1

func set_outline(value: bool):
	$Container/Outline.visible = value
