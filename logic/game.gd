extends Node

var you: Player = Player.new()
var players: Array[Player] = [you, Player.new()]

@onready var table: Node2D = get_node("/root/Table")
@onready var ui: CanvasLayer = table.get_node("UI")


func _ready():
	ui.add_child(load("res://node/hand.tscn").instantiate())



# other

func wait_for_the_engine_to_stop_being_silly():
	for i in 5: await get_tree().process_frame
