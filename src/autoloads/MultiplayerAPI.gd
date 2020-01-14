"""
 Multiplayer API. Handles game packets between players
 so they can sync their game state.
"""
extends Node


onready var imp : Node = get_node( "MultiImplementation" )


func call_remote_method( method_name : String, object_to_call : Object = self,
						arguments : Array = [] ) -> void :
	object_to_call.rpc( method_name, arguments )


func connect_to_player( ip4_address : String ) -> bool :
	#Connect to the player specified by ip4_address.
	#Returns true if connection was succesful. False otherwise.
	return imp.connect_to_server( ip4_address )


func start_hosting() -> void :
	#Begin accepting connections from other players.
	#The other player will need to provide my ip address.
	imp.set_as_server()
