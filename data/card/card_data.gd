class_name CardData extends Resource


@export var name: String = "Card"
@export_multiline var text: String

enum Type {
	BASIC
}
@export var type: Type

@export var front_art: Texture2D
@export var back_art: Texture2D


func assign(card: Card):
	card.card_name = name
	card.front_art = front_art
	card.back_art = back_art
