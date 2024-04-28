class_name Actor extends Card



# health

signal health_changed

var health: int = 0:
	set(value):
		health = value
		health_changed.emit()

func damage(amount: int):
	health -= amount

func heal(amount: int):
	health += amount



# attack

signal attack_changed

var attack: int = 0:
	set(value):
		attack = value
		attack_changed.emit()

func attack_card(card: Card):
	card.damage(attack)



# attributes

var attributes: Array[String] = []

func add_attribute(attribute: String):
	attributes.append(attribute)

func has_attribute(attribute: String):
	return attribute in attributes

func remove_attribute(attribute: String):
	attributes.erase(attribute)



# data path

func data_path(): return super() + "actor/"
