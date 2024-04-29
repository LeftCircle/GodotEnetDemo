extends Node

signal player_connected(network_id)
signal player_disconnected(network_id)

var is_server : bool = false

var network = ENetMultiplayerPeer.new()
var server_api = SceneMultiplayer.new()
var connected_players = []
var packet : PackedByteArray = PackedByteArray([])

func execute():
	server_api.poll()
	#if is_server:
		#for id in connected_players:
			#var peer : ENetPacketPeer = network.get_peer(id)
			#print("RTT = %s" % [peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)])

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
	var peer : PacketPeer = network.get_peer(id)
	var rtt : int = peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	Logging.log_line("Packet from server received! rtt = %s" % [rtt])

func _on_packet_from_server(id : int, byte_array) -> void:
	#print("Packet from server %s" % [byte_array])\
	byte_array = PackedByteArray(byte_array)
	var peer : PacketPeer = network.get_peer(id)
	var rtt : int = peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	var s_frame = byte_array.decode_u64(0)
	Logging.log_line("Packet from server received! rtt = %s. Sent frame = %s" % [rtt , s_frame])

func send_packet() -> void:
	if is_server:
		var b_array : PackedByteArray = PackedByteArray([])
		b_array.resize(8)
		b_array.encode_u64(0, CommandFrame.frame)
		server_api.send_bytes(b_array, 0, MultiplayerPeer.TRANSFER_MODE_UNRELIABLE, 2)
		Logging.log_line("Sending packet for frame %s" % [CommandFrame.frame])
		#var server = network.get_peer(0)
		#for id in connected_players:
			##var peer : ENetPacketPeer = network.get_peer(id)
			#server.send(id, packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)
		pass

