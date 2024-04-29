extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

var is_server : bool = false

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var connected_players = []
var packet : PackedByteArray = PackedByteArray([])

func _physics_process(delta):
	server_api.poll()
	if is_server:
		for id in connected_players:
			var peer : ENetPacketPeer = network.get_peer(id)
			print("RTT = %s" % [peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)])

func _ready():
	packet.resize(40)

func start_server() -> void:
	is_server = true
	var server_initalizer = ServerInitializer.new()
	server_initalizer.init_server(get_tree(), network, server_api, self)

func start_client() -> void:
	print("Starting client...")
	var client_init = ClientInitializer.new()
	client_init.init_client(get_tree(), network, server_api, self)

func _on_peer_connected(player_id):
	if is_server:
		print("PEER CONNECTED!!")
		var packet_peer : ENetPacketPeer = network.get_peer(player_id)
		var n_channels = packet_peer.get_channels()
		print("N_channels = %s" % [n_channels])
		emit_signal("player_connected", player_id)
		connected_players.append(player_id)

func _on_peer_disconnected(player_id):
	if is_server:
		print("peer disconnected")
		emit_signal("player_disconnected", player_id)
		connected_players.erase(player_id)

func _on_packet_from_client(id : int, byte_array) -> void:
	print("Packet from client")

func _on_packet_from_server(id : int, byte_array) -> void:
	print("Packet from server %s" % [byte_array])

func send_packet() -> void:
	if is_server:
		#server_api.send_bytes([1, 2, 3], 0, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE, 2)
		#var server = network.get_peer(0)
		#for id in connected_players:
			##var peer : ENetPacketPeer = network.get_peer(id)
			#server.send(id, packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)
		pass

