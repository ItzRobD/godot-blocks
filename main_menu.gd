extends Control

signal button_pressed

@onready var button: Button = %Button
@onready var label: Label = %Label

func _on_button_pressed() -> void:
	button_pressed.emit()

func set_main_menu() -> void:
	label.text = "T3-TR15" 
	button.text = "Start Game" 
	
func set_game_over_menu() -> void:
	label.text = "Game Over" 
	button.text = "Restart" 
