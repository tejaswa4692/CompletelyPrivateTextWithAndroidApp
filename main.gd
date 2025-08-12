extends Control

var ws = parent.websocket
var username := parent.user
var username_sent := false

@onready var chat_log: TextEdit = $VBoxContainer/ChatLog
@onready var message_input: LineEdit = $VBoxContainer/HBoxContainer/MessageInput
@onready var send_button: Button = $VBoxContainer/HBoxContainer/SendButton

func _ready():
	send_button.pressed.connect(_on_send_pressed)

	#var server_url = "ws://"+ ip + ":8765" # Replace with your forwarded IP
	#var err = ws.connect_to_url(server_url)
	#if err != OK:
		#push_error("Connection error: %s" % err)

	set_process(true)

func _process(_delta):
	ws.poll()

	match ws.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			 #Send username first, once connected
			if not username_sent:
				ws.send_text(username)
				username_sent = true
			while ws.get_available_packet_count() > 0:
				var pkt = ws.get_packet().get_string_from_utf8()
				append_chat(pkt)

				
		WebSocketPeer.STATE_CLOSED:
			chat_log.append_text("[Disconnected from server]\n")

func _on_send_pressed():
	var msg = message_input.text.strip_edges()
	if msg != "":
		if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ws.send_text(msg)
		message_input.text = ""

func append_chat(text_to_add: String):
	chat_log.text += text_to_add + "\n"
	chat_log.scroll_vertical = chat_log.get_line_count()  # auto scroll to bottom
