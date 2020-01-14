"""
  Implements lobby functionality.
 Only Multi is allowed to call this.
"""
extends Node

var connection : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()


func _ready() -> void :
	#Connect to all the signals that handle networking.
	#warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "player_connected")
	#warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	#warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "connected_ok")
	#warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "connected_fail")
	#warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "server_disconnected")

	connection.set_transfer_mode( 2 ) 


func connect_to_server( ip4_address : String ) -> bool :
	#Connect to another player.
	var error : bool = connection.create_client( ip4_address, 1 )
	return error


# warning-ignore:unused_argument
func player_disconnected( player_id : int) -> void :
	#Player has disconnected from me when I am a server.
	get_tree().refuse_new_network_connections = false


# warning-ignore:unused_argument
func player_connected( player_id : int ) -> void :
	#A player has connected. Refuse new connections.
	get_tree().refuse_new_network_connections = true


func set_as_server() -> void :
	#Set myself up as a server.
	get_tree().set_network_peer( get_tree().network_peer )
