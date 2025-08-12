extends Control


var ws = parent.websocket

@onready var username_container := $Name
@onready var ip_container := $ip



func _on_button_pressed() -> void:
	if username_container.text != "" and typeof(username_container.text) == TYPE_STRING:
		if ip_container.text != "" and typeof(ip_container.text) == TYPE_STRING:
			var server_url = "ws://"+ ip_container.text + ":8765" # Replace with your forwarded IP
			var err = ws.connect_to_url(server_url)
			if err != OK:
				push_error("Connection error: %s" % err)
			#if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
			parent.user = username_container.text
			parent.ip = ip_container.text
			get_tree().change_scene_to_file("res://main.tscn")
		else:
			pass
	else:
		pass
