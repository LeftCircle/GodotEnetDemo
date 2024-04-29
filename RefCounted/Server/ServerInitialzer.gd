extends RefCounted
class_name ServerInitializer

var port : int = 28836
var max_players : int = 100
var max_channels : int = 3

func init_server(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node) -> void:
	connect_and_check_connection(scene_tree, network, server_api, server_node)
	_connect_signals(network, server_api, server_node)

func connect_and_check_connection(scene_tree : SceneTree, network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node):
	var server_status = network.create_server(port, max_players, max_channels)
	_check_status(server_status)
	server_api.multiplayer_peer = network
	var server_node_path : NodePath = server_node.get_path()
	server_api.root_path = server_node_path
	scene_tree.set_multiplayer(server_api, server_node_path)
	scene_tree.multiplayer_poll = false

func _connect_signals(network : ENetMultiplayerPeer, server_api : SceneMultiplayer, server_node : Node):
	print("Server has started!!")
	network.peer_connected.connect(server_node._on_peer_connected)
	network.peer_disconnected.connect(server_node._on_peer_disconnected)
	server_api.peer_packet.connect(server_node._on_packet_from_client)

func _check_status(status) -> void:
	if status != OK:
		OS.alert("Server creation failed")


