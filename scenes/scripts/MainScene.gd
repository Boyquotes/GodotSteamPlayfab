extends Node

func _ready():
	if OS.has_feature("__clientBuild"):
		get_tree().change_scene_to_file("res://scenes/GameClient.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/GameServer.tscn")
		
