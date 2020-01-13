"""
 Multiplayer API. Handles game packets between players
 so they can sync their game state.
"""
extends Node


func call_remote_method( method_name : String, object_to_call : Object = self,
						arguments : Array = [] ) -> void :
	object_to_call.rpc( method_name, arguments )


func connect_to_player( ip4_address : String ) -> bool :
	#Connect to the player specified by ip4_address.
	#Returns true if connection was succesful. False otherwise.
	return false
