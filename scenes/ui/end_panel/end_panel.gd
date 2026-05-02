extends Panel
class_name EndPanel

signal menu_button_pressed
signal restar_button_pressed
signal game_end
@onready var game_statc_show: RichTextLabel = %GameStatcShow
@onready var win_text_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/WinTextLabel
@onready var lose_text_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/LoseTextLabel

func _ready() -> void:
	Game.game_lose.connect(show_end.bind(false))
	Game.game_win.connect(show_end.bind(true))

func show_end(is_win:bool = true):
	Global.game_paused = true
	game_end.emit()
	_set_statistic()
	if is_win:
		win_text_label.show()
		lose_text_label.hide()
	else:
		win_text_label.hide()
		lose_text_label.show()
	show()

func _on_menu_pressed() -> void:
	menu_button_pressed.emit()
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	restar_button_pressed.emit()
	pass # Replace with function body.

func _set_statistic():
	var statistic := Global.game_statistic
	var message:String = ""
	for sta in statistic:
		message += sta+ ":" + str(statistic[sta])+"\n"
	game_statc_show.text = message
