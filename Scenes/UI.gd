extends Control


func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	Server.send_packet()

func _on_server_button_pressed() -> void:
	Server.start_server()

func _on_client_button_pressed() -> void:
	Server.start_client()
	$SendPackets.disabled = true

func _on_send_packets_pressed() -> void:
	print("Syncing command frame then sending packets")
	Server.send_frame_sync()
	set_physics_process(true)

