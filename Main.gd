extends Node


func _physics_process(delta: float) -> void:
	CommandFrame.execute()
	Server.execute()

