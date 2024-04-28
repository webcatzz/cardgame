class_name ActorData extends CardData


@export_range(0, 30) var health: int = 1
@export var attack: int = 1


func assign(card):
	super(card)
	card.health = health
	card.attack = attack
