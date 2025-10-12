extends Control

func _ready():
	$VBoxContainer/HostButton.pressed.connect(Callable(self, "_on_host_pressed"))
	$VBoxContainer/JoinButton.pressed.connect(Callable(self, "_on_join_pressed"))

func _on_host_pressed():
	NetworkManager.host_game()
	UIManager.show_lobby()

func _on_join_pressed():
	var address = $VBoxContainer/AddressEntry.text
	if address == "":
		address = "127.0.0.1"
	NetworkManager.join_game(address)
	UIManager.show_lobby()
